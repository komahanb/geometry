"""
Python script to setup the files necessary for flexible multibody
dynamics simulation in TACS.

The goal is to prepare:
.bdf : files for each body containing mesh for visualization
.inp : files for each body containing inertial properties and initial conditions

The mesh, inertial properties and initial conditions are required by
TACSBuilder class for creating TACS.

This script basically takes us from GEO to ANALYSIS.

Input:
prefix : root directory of simulation

Output:
prefix/bdf  --> will contain the .BDF files
prefix/brep --> will contain the .BREP files
prefix/inp  --> will contain the .INP files

Author: Komahan Boopathy (komahan@gatech.edu)
"""
import numpy as np
import sys, os
from subprocess import call

class Body(object):
    def __init__(self, name, geo_file, processBC):
        # Basic information about the body
        self.name                = name
        self.geo_file            = geo_file
        self.processBC           = processBC

        # These are needed for each body to create TACS
        self.mesh_file           = None
        self.brep_file           = None        
        self.initial_conditions  = None
        self.solid_props = None
        self.mesh_numbering = 1 #'coordinate'
        
        # Initial conditions
        self.velocity = np.array([0.0,0.0,0.0])
        self.omega = np.array([0.0,0.0,0.0])
        self.grav = np.array([0.0,0.0,-9.81])

        # solid prop
        self.density = 1.0

        return
    
class BREPGenerator(object):
    @staticmethod
    def generate(body):
        """
        Generate the GEO file by calling GMSH for the body supplied as
        argument
        """
        # output BREP file
        body.brep_file = prefix + 'brep/' + body.geo_file + '.brep'

        # Create BREP file
        call(["gmsh", body.geo_file + '.geo', "-0", "-o", body.brep_file])
        return

class BDFGenerator(object):
    @staticmethod
    def getGmshOptions(tag_type):
        '''
        These are the options that we use for our purposes in TACS
        '''
        gmsh_string = "Mesh.Optimize = 1; Mesh.SubdivisionAlgorithm = 1; Mesh.RecombinationAlgorithm = 1; Mesh.RecombineAll = 1; Mesh.RemeshAlgorithm = 0; Mesh.RemeshParametrization = 0; Mesh.RefineSteps = 10; Mesh.ElementOrder=2; Mesh.BdfFieldFormat=2; Mesh.Format=31; Mesh.SaveElementTagType=%d;" % tag_type
        return gmsh_string

    @staticmethod
    def generate(body):
        """
        Generate the BDF file by calling GMSH for the body supplied as
        argument
        """
        # use the BREP file as input geoemtry file
        #geometry_file = prefix + 'brep/' +  body.geo_file + '.brep'
        geometry_file = body.geo_file + '.geo'

        # Store where the mesh is located into the body
        body.mesh_file = prefix + 'bdf/' + body.geo_file + '.bdf'

        # Create mesh (this does not supply any body specific options
        # defined in the .geo file)
        call(["gmsh",
              geometry_file,
              "-2",
              "-o", body.mesh_file,
              "-string", BDFGenerator.getGmshOptions(1)])
        
        # remove cbar entries
        call(["sed", "-i", "/CBAR/d", body.mesh_file])
        return

import sys
sys.path.append("/usr/lib/freecad/lib")
import FreeCAD, Part
class SolidProperties:
    @staticmethod
    def generate(body):
        """
        Evaluates the solid properties using FREECAD that uses
        OPENCASCADE geoemtry engine
        """
        Part.open(body.brep_file)
        key = os.path.basename(body.brep_file).split('.brep')[0]
        doc = App.getDocument(key)
        doc.recompute()        
        shape = doc.getObject(key).Shape
        body.solid_props = shape.Solids[0]
        return
    
    @staticmethod
    def writeProps(body):
        """
        Write the solid properties to file
        """
        solid = body.solid_props
        prop_file = prefix + 'inp/' + body.geo_file + '.inp'

        # Store the location of prop file into the body
        body.solid_prop_file = prop_file
        
        print "Creating solid property file", body.solid_prop_file
        
        c = [0.0, 0.0, 0.0]
        Jmat = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        xcm = [0.0, 0.0, 0.0]
        
        CTMP = [solid.StaticMoments[0],
                solid.StaticMoments[1],
                solid.StaticMoments[2]]
        J = solid.MatrixOfInertia
        JTMP = [J.A11, J.A12, J.A13, J.A22, J. A23, J.A33]
        xcmtmp = [solid.CenterOfMass.x,
                  solid.CenterOfMass.y,
                  solid.CenterOfMass.z]
        
        for i in xrange(3):
            if abs(CTMP[i]) > 1.0e-16:
                c[i] = CTMP[i]
                xcm[i] = xcmtmp[i]

        for i in xrange(6):
            if abs(JTMP[i]) > 1.0e-16:
                Jmat[i] = JTMP[i]

        # Assert the equivalence of xcg and c/volume
        assert((np.allclose(np.array(xcm), np.array(c)/solid.Volume)), 1)
        omega = body.omega
        grav = body.grav
        v = body.velocity
        fp = open(body.solid_prop_file, 'w')   
        fp.write('name %s\n' % body.name)
        fp.write('density %s\n' % body.density)
        fp.write('volume %s\n' % solid.Volume)
        fp.write('c %s %s %s\n' % (c[0], c[1], c[2]))
        fp.write('J %s %s %s %s %s %s\n' % (Jmat[0], Jmat[1], Jmat[2],
                                            Jmat[3], Jmat[4], Jmat[5]))
        fp.write('xcg %s %s %s\n' % (xcm[0], xcm[1], xcm[2]))
        fp.write('vel %s %s %s\n' % (v[0], v[1], v[2]))
        fp.write('omega %s %s %s\n' % (omega[0], omega[1], omega[2]))
        fp.write('grav %s %s %s\n' % (grav[0], grav[1], grav[2]))
        fp.write('mesh %s %s\n' % (body.geo_file + '.bdf', body.mesh_numbering))
        fp.close()
    
######################################################################   
######################################################################

prefix = '/home/komahan/git/tacs-problems/tail_sitter/'

if not os.path.exists(prefix):
    os.makedirs(prefix)
    
# Make necessary directories for BREP/BDF/INP files
if not os.path.exists(prefix + "brep"):
    os.makedirs(prefix + "brep")
    
# Make necessary directories for BREP/BDF/INP files
if not os.path.exists(prefix + "inp"):
    os.makedirs(prefix + "inp")

# Make necessary directories for BREP/BDF/INP files
if not os.path.exists(prefix + "bdf"):
    os.makedirs(prefix + "bdf")
    
# All the bodies to setup for simulation
bodies = []
bodies.append(Body("Hub1", "hub1" , False))
bodies.append(Body("Blade1Hub1"  , "bladeh11" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("Blade2Hub1"  , "bladeh12" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("Blade3Hub1"  , "bladeh13" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("Blade4Hub1"  , "bladeh14" , False))
bodies[-1].omega[0] = -109.12

bodies.append(Body("Hub2", "hub2" , False))
bodies.append(Body("Blade1Hub2"  , "bladeh21" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("Blade2Hub2"  , "bladeh22" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("Blade3Hub2"  , "bladeh23" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("Blade4Hub2"  , "bladeh24" , False))
bodies[-1].omega[0] = 109.12

bodies.append(Body("Fuselage" , "body" , False))
bodies.append(Body("TailBase" , "tailbase" , False))

# Add blade assembly
bodies.append(Body("TailAssembly45Hub" , "tail_assembly45_hub" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("TailAssembly45Blade1"  , "tail_assembly45_blade1" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("TailAssembly45Blade2"  , "tail_assembly45_blade2" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("TailAssembly45Blade3"  , "tail_assembly45_blade3" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("TailAssembly45Blade4"  , "tail_assembly45_blade4" , False))
bodies[-1].omega[0] = -109.12

bodies.append(Body("TailAssembly225Hub" , "tail_assembly225_hub" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("TailAssembly225Blade1"  , "tail_assembly225_blade1" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("TailAssembly225Blade2"  , "tail_assembly225_blade2" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("TailAssembly225Blade3"  , "tail_assembly225_blade3" , False))
bodies[-1].omega[0] = -109.12
bodies.append(Body("TailAssembly225Blade4"  , "tail_assembly225_blade4" , False))
bodies[-1].omega[0] = -109.12

bodies.append(Body("TailAssembly135Hub" , "tail_assembly135_hub" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("TailAssembly135Blade1"  , "tail_assembly135_blade1" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("TailAssembly135Blade2"  , "tail_assembly135_blade2" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("TailAssembly135Blade3"  , "tail_assembly135_blade3" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("TailAssembly135Blade4"  , "tail_assembly135_blade4" , False))
bodies[-1].omega[0] = 109.12

bodies.append(Body("TailAssembly315Hub" , "tail_assembly315_hub" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("TailAssembly315Blade1"  , "tail_assembly315_blade1" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("TailAssembly315Blade2"  , "tail_assembly315_blade2" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("TailAssembly315Blade3"  , "tail_assembly315_blade3" , False))
bodies[-1].omega[0] = 109.12
bodies.append(Body("TailAssembly315Blade4"  , "tail_assembly315_blade4" , False))
bodies[-1].omega[0] = 109.12

# Generate BREP file for body
for body in bodies:
    print "GEOHelper: Generating BREP file for body:", body.name
    BREPGenerator.generate(body)
    
    print "GEOHelper: Generating BREP file for body:", body.name    
    SolidProperties.generate(body)
    SolidProperties.writeProps(body)

    print "GEOHelper: Generating BDF file for body:", body.name
    BDFGenerator.generate(body)
