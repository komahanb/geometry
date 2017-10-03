"""
Python script to handle the BDF file generation from GMSH in a form
that is directly compatible with TACS. The key steps are:

1. Using the .geo file run gmsh and generate a temporary BDF
file. This temporary BDF file will have elements that are not required
by TACS (e.g. CBAR) entries. Also, the CQUAD9 elements will have
component ID that do not start with 1.

2. Load the temporary BDF file into memory and reindex all the
component numbers so that they start with 1. These settings go into a
temporary .geo file.

3. Execute gmsh using the temporary .geo file which will produce a BDF
file that can be used in TACS.

Caution: Note that the boundary conditions need to be set and needs to
be handled manually by the user. The python script generate_bc.py can
be used for this purpose.

python generate_bc.py --bdf_file=rotor.bdf --boundary_component=1
"""

# Import some utilities
import numpy as np
import argparse
import sys, traceback
from subprocess import call

# Parse the command line arguments
parser = argparse.ArgumentParser()
parser.add_argument('--geometry' , type=str, default=None, help='Input geometry file for gmsh')
parser.add_argument('--mesh'     , type=str, default=None, help='Output BDF mesh file')
args = parser.parse_args()

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
    gmsh_string = "Mesh.CharacteristicLengthExtendFromBoundary = 1; Mesh.CharacteristicLengthFactor = 0.5; Mesh.CharacteristicLengthMin = 0; Mesh.CharacteristicLengthMax = 1.0; Mesh.CharacteristicLengthFromCurvature = 0; Mesh.CharacteristicLengthFromPoints = 1; Mesh.Optimize = 1; Mesh.SubdivisionAlgorithm = 1; Mesh.RecombinationAlgorithm = 1; Mesh.RecombineAll = 1; Mesh.RemeshAlgorithm = 0; Mesh.RemeshParametrization = 0; Mesh.RefineSteps = 10; Mesh.ElementOrder=2; Mesh.BdfFieldFormat=2; Mesh.Format=31; Mesh.SaveElementTagType=%d;" % tag_type
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

def getNodesForComponentID(comp_id):
    '''
    Returns the nodes associated with the supplied component ID. This
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
    return sorted(remove_duplicates(node_ids))

def writeBCForComponent(cid):
    '''
    A function that writes SPC boundary conditions on the nodes
    beloging to the input component ID (cid). This is written into a
    separate file. The user is expected to copy this into the BDF or
    can process separately depending on how he wishes to handle
    boundary conditions.
    '''
    fp = open(bc_file, 'w')
    bc_nodes = getNodesForComponentID(cid)

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

def getBCID(eids, bc_cid=None, bc_nodes=None):
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
#                Calling main program                                 #
#######################################################################

# Get the INPUT geometry file
geometry_file  = args.geometry
if geometry_file is None:
    print "No input .geo file specified. Exiting..."
print "Geometry file : ", geometry_file

# The output BDF file
mesh_file      = args.mesh
if mesh_file is None:
    mesh_file = geometry_file.split('.geo')[0] + '.bdf'
print "Mesh file     : ", mesh_file

## Get the number of components
## num_components = args.num_components
## if num_components is not None:
##     physical_surface = 1
## else:
##     physical_surface = 0

physical_surface = 0

# Execute gmsh with the geo file with tag 
call(["gmsh", geometry_file, "-o", mesh_file, "-string", getGmshOptions(1), "-2"])

# Read the contents of the generated BDF file from GMSH. We read the
# BDF file to identify the nodes to which the BCs need to be applied
bdf = readInputFile(mesh_file)

# Get the list all the physical component ids defined in the mesh
print "Component IDs in the mesh"
cids = getComponentIDs(bdf)
print  cids
num_components = len(cids)
print "Number of components : ", len(cids)

# Execute gmsh with the new geo file containing physical surfaces
#tmp_geo_file = geometry_file + '.tmp'
#writeRenumberedComponents(tmp_geo_file, cids)
#call(["gmsh", tmp_geo_file, "-o", mesh_file, "-string", getGmshOptions(2), "-2"])

## # The user might already know the node ids that are subject to
## # boundary conditions
## bc_id    = args.bc_id
## if bc_id is not None:
##     print "BC id         : ", bc_id

## # BC identifier nodes
## if bc_id is None:
##     bc_nodes = args.bc_nodes
##     print "BC nodes      : ", bc_nodes
## else:
##     bc_nodes = None

## # Determine the name of the BC file
## if bc_id is None and bc_nodes is None:
##     exportBC = False
##     print "Export BC     : ", False
## else:
##     exportBC = True
##     bc_file = mesh_file+'.bc'
##     print "Export BC     : ", exportBC
##     print "BC File       : ", bc_file

## # Get the boundary condition ID
## print "bc_id: ", bc_id
## print "bc_nodes: ", bc_nodes
## bc_id_found = getBCID(physical_ids, bc_id, bc_nodes)
## print "bc_id_found", bc_id_found

## # Print all the nodes in the BC surface
## print "Finding nodes belonging to BC ID:", bc_id_found
## nodes = getNodesForComponentID(bc_id_found)
## print "Boundary nodes are : ", nodes
## print "Total nodes : ", len(nodes)

## # Write out the BC as a separate file
## if exportBC and len(nodes) > 0:
##     print "BCs writted out as "+ bc_file
##     writeBCForComponent(bc_id_found)
