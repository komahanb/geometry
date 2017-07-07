"""
python generate_bc.py --bdf_file=rotor.bdf --boundary_component=1
"""
# Import some utilities
import numpy as np
import argparse
import sys, traceback
from subprocess import call

# Parse the command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--bdf_file', type=str, default=None, help='BDF file')
parser.add_argument('--boundary_components', type=str, default=None, help='The component number of the BC surface')
parser.add_argument('--boundary_nodes', type=str, default=None, help='The node numbers to write as SPC entries')
args = parser.parse_args()

def strtolist(mStr):
    if mStr is None:
        return []
    return [int(e) if e.isdigit() else e for e in mStr.split(',')]
    
def readInputFile(filename):
    """
    Method to read the input file and return the data as string.
    """
    try:
        inpFile = open(filename, "r")
        content = list(inpFile.readlines())
        inpFile.close()
    except:
        raise IOError
    return content

def getGmshOptions(tag_type):
    '''
    These are the options that we use for our purposes in TACS
    '''
    gmsh_string = "Mesh.ElementOrder=2; Mesh.Algorithm=8; Mesh.SubdivisionAlgorithm=1; Mesh.BdfFieldFormat=2; Mesh.Format=31; Mesh.SaveElementTagType=%d;" % tag_type
    return gmsh_string

def remove_duplicates(x):
    '''
    Removes duplicates in a list
    '''
    a = []
    for i in x:
        if i not in a:
            a.append(i)
    return a

def getComponentIDs(bdf):
    '''
    Gets the list of physical component IDs in the file. The component
    ID to which each CQUAD9 element belongs is the third entry in the
    bulk data deck.

    Example:
    CQUAD9  85589   26      44282   44280   43652   44253   46654   46646   +E85589
    +E85589 46531   46656   46657

    where EID = 85589, PID = 26, followed by 9 nodeIDs forming the
    element.
    '''
    tag = []
    for line in bdf:
        entry = line.split()
        if entry[0] == "CQUAD9":
            tag.append(int(entry[2]))
    return remove_duplicates(tag)

def getCBARNodesForComponentID(bc_nodes):
    '''
    Returns the nodes associated with the supplied element ID. This
    call is useful to set boundary conditions on the nodes belonging
    to this component id as SPC entries.
    
    Example: CBAR 85589 26 44 42 43

    where EID = 85589, CID = 26, followed by the 9 nodeIDs forming the
    element.
    '''

    # Create an empty list for storing the node ids belonging to the
    # component id
    cbarnode_ids  = []

    # Logic to append 9 nodes of each CQUAD elements into the list
    for line in bdf:
        entry = line.split()
        if entry[0] == "CBAR" and set([int(entry[3]), int(entry[4]), int(entry[5])]).issubset(bc_nodes):
            # Append the cbar node indices to the list
            cbarnode_ids.append([int(entry[3]), int(entry[4]), int(entry[5])])

    return cbarnode_ids

def getNodesForComponentID(comp_id):
    '''
    Returns the nodes associated with the supplied element ID. This
    call is useful to set boundary conditions on the nodes belonging
    to this component id as SPC entries.
    
    Example: CQUAD9 85589 26 44282 44280 43652 44253 46654 46646
    +E85589 +E85589 46531 46656 46657

    where EID = 85589, CID = 26, followed by the 9 nodeIDs forming the
    element.
    '''

    # Create an empty list for storing the node ids belonging to the
    # component id
    node_ids  = []

    # Logic to append 9 nodes of each CQUAD elements into the list
    skip = False
    for line in bdf:
        entry = line.split()
        if entry[0] == "CQUAD9" and int(entry[2]) == comp_id:
            # Append the BC node indices to the list
            node_ids.append(int(entry[3]))
            node_ids.append(int(entry[4]))
            node_ids.append(int(entry[5]))
            node_ids.append(int(entry[6]))
            node_ids.append(int(entry[7]))
            node_ids.append(int(entry[8]))
            
            # parse the continuations next time
            skip = True
        
        elif skip:
            # Append the BC node indices to the list
            node_ids.append(int(entry[1]))
            node_ids.append(int(entry[2]))
            node_ids.append(int(entry[3]))
            
            # Now turn off the continuations
            skip = False

    # The node_id list will contain duplicates, so we remove
    # duplicates. Also we sort the list for usefulness.
    return remove_duplicates(node_ids)

def writeBCForComponent(cid,bc_nodes):
    '''
    A function that writes SPC boundary conditions on the nodes
    beloging to the input component ID (cid). This is written into a
    separate file. The user is expected to copy this into the BDF or
    can process separately depending on how he wishes to handle
    boundary conditions.
    '''
    fp = open(bc_file, 'w')

    # If BC nodes are present write as SPC entries
    num_bc_nodes = len(bc_nodes)
    if num_bc_nodes != 0:
        # Set up the plate so that it is fully clamped
        for i in xrange(num_bc_nodes):
            # Set the y = const edges
            spc = '123'
            fp.write('%-8s%8d%8d%8s%8.6f\n'%
                     ('SPC', 1, bc_nodes[i], spc, 0.0))                
    fp.close()
    return

def writeCBAREntries(file,cbar_nodes,bc_nodes):
    '''
    A function that writes CBAR nodes to file
    '''
    fp = open(file, 'w')
    num_cbar_nodes = len(cbar_nodes)/3
    if num_cbar_nodes != 0:
        for nodes in cbar_nodes:
            fp.write('%-8s%8d%8d%8d\n'% ('CBAR',
                                         nodes[0], nodes[1], nodes[2]))
    fp.close()
    return

def writeBCForNodes(bc_file, bc_nodes):
    '''
    A function that writes SPC boundary conditions on the nodes that
    are user supplied or determined otherwise.
    '''
    fp = open(bc_file, 'w')
    # If BC nodes are present write as SPC entries
    num_bc_nodes = len(bc_nodes)
    if num_bc_nodes != 0:
        # Set up the plate so that it is fully clamped
        for i in xrange(num_bc_nodes):
            # Set the y = const edges
            spc = '123'
            fp.write('%-8s%8d%8d%8s%8.6f\n'%
                     ('SPC', 1, bc_nodes[i], spc, 0.0))                
    fp.close()
    return

def writeRenumberedComponents(tmp_geo_file, cids):
    '''
    The physical surfaces (components) in the BDF file do not start
    from one (1). This is not compatible with TACS. So we
    '''
    if physical_surface == 1:
        fp = open(tmp_geo_file, 'w')
        fp.write('Merge "%s";\n' % mesh_file)
        # Label all elements as belonging to one component
        fp.write('Physical Surface(1)={')
        ctr = 0
        for id in cids:
            ctr += 1
            fp.write('%d' % id)
            if ctr < len(ids):
                fp.write(',')
        fp.write('};\n')
        fp.close()        
    else:
        fp = open(tmp_geo_file, 'w')
        fp.write('Merge "%s";\n' % mesh_file)
        ctr = 0
        for id in cids:
            ctr += 1
            # Label as belonging to one component starting with 1
            fp.write('Physical Surface(%d)={%d};\n' % (ctr, id))
        fp.close()
    return

def getBCID(eids, bc_id=None, bc_nodes=None):
    '''
    Return the node numbers associated with the BC. This is a code
    code that operates based on some assumptions, which can quite not
    be true under circumstances.
    '''
    if bc_id is not None:
        # user already provided the bc_surface_id as input argument
        write_bc = False        
        # Check if the id does exist in the mesh
        for eid in eids:
            if eid == bc_id:
                write_bc = True
                break
        return bc_id
    else:
        write_bc = False
        if bc_nodes is not None:
            # find bc_id based on nodes provided
            for eid in eids:
                nodes = getNodesForComponentID(eid)
                print eid, nodes
                if bc_nodes[0] in nodes and bc_nodes[1] in nodes:
                    bc_id = eid
                    print "Found BC surface", eid
                    write_bc = True
                    return bc_id
                
#######################################################################
#                Process BC from supplied BDF file                    #
#######################################################################

# The input BDF file
bdf_file      = args.bdf_file
print "BDF file : ", bdf_file

# Read the contents of the generated BDF file from GMSH. We read the
# BDF file to identify the nodes to which the BCs need to be applied
bdf = readInputFile(bdf_file)

# The user might already know the component id that is subject to
# boundary conditions
bc_cids = strtolist(args.boundary_components)
if len(bc_cids) != 0:
    # Check if the user supplied boundary component is indeed present 
    cids = getComponentIDs(bdf)
    print "The available componets in the mesh are:"
    print cids
    for bc_cid in bc_cids:
        if bc_cid not in cids:
            print 'Component %d is not present in the bdf file' % (bc_cid)
            exit
        else:
            # Write out the BC in a separate file
            suffix = '.comp%d' % (bc_cid)
            bc_file = bdf_file + suffix + '.bc'
            print "BCs written out as " + bc_file
            bc_nodes = getNodesForComponentID(bc_cid)
            writeBCForComponent(bc_cid, bc_nodes)
            
            # Write the list of CBAR elements along the boundary surface
            cbar_file = bdf_file.split(".bdf")[0] + '.cbar'
            print "CBARs written out as " + cbar_file
            cbar_nodes = getCBARNodesForComponentID(bc_nodes)
            writeCBAREntries(cbar_file, cbar_nodes, bc_nodes)


# Write out the user supplied BC nodes as SPC entries in a separate
# file
bc_nodes = strtolist(args.boundary_nodes)
print "User specified BC nodes are:", bc_nodes
if len(bc_nodes) != 0:
    bc_file = bdf_file + '.nodes' + '.bc'
    print "BCs written out as " + bc_file
    writeBCForNodes(bc_file, bc_nodes)
    

    
