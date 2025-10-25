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
        self.density = 7200.0

        return

class BREPGenerator(object):
    @staticmethod
    def generate(body):
        """
        Generate the GEO file by calling GMSH for the body supplied as
        argument
        """
        # output BREP file
        body.brep_file = prefix + os.sep + 'brep/' + body.geo_file + '.brep'

        # Create BREP file
        call(["gmsh", prefix + os.sep + 'geo/' + body.geo_file + '.geo', "-0", "-o", body.brep_file])
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
        geometry_file = prefix + os.sep + 'geo/' + body.geo_file + '.geo'

        # Store where the mesh is located into the body
        body.mesh_file = prefix + os.sep + 'bdf/' + body.geo_file + '.bdf'

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
        prop_file = prefix + os.sep + 'inp/' + body.geo_file + '.inp'

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

prefix = os.getcwd()
#prefix = '/home/komahan/git/tacs-problems/rotor-assembly/'
#prefix = '/home/komahan/git/tacs-problems/hart-assembly/'

if not os.path.exists(prefix):
    os.makedirs(prefix)

# Make necessary directories for BREP/BDF/INP files
if not os.path.exists(prefix + os.sep + "brep"):
    os.makedirs(prefix + os.sep + "brep")

# Make necessary directories for BREP/BDF/INP files
if not os.path.exists(prefix + os.sep+ "inp"):
    os.makedirs(prefix + os.sep + "inp")

# Make necessary directories for BREP/BDF/INP files
if not os.path.exists(prefix + os.sep+ "bdf"):
    os.makedirs(prefix + os.sep + "bdf")

# All the bodies to setup for simulation
bodies = []
bodies.append(Body("BladeCapAt0Deg"         , "bcap0"    , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("BladeCapAt90Deg"        , "bcap90"   , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("BladeCapAt180Deg"       , "bcap180"  , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("BladeCapAt270Deg"       , "bcap270"  , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("BladeAt0Deg"            , "blade0"   , True))
bodies[-1].omega[2] = 109.12
bodies.append(Body("BladeAt90Deg"           , "blade90"  , True))
bodies[-1].omega[2] = 109.12
bodies.append(Body("BladeAt180Deg"          , "blade180" , True))
bodies[-1].omega[2] = 109.12
bodies.append(Body("BladeAt270Deg"          , "blade270" , True))
bodies[-1].omega[2] = 109.12
bodies.append(Body("LowerPitchLinkAt30Deg"  , "lpl30"    , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("LowerPitchLinkAt120Deg" , "lpl120"   , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("LowerPitchLinkAt210Deg" , "lpl210"   , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("LowerPitchLinkAt300Deg" , "lpl300"   , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("UpperPitchLinkAt30Deg"  , "upl30"    , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("UpperPitchLinkAt120Deg" , "upl120"   , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("UpperPitchLinkAt210Deg" , "upl210"   , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("UpperPitchLinkAt300Deg" , "upl300"   , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("Hub4Bladed"             , "hub4b"    , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("UpperSwashPlate4Bladed" , "usp4b"    , False))
bodies[-1].omega[2] = 109.12
bodies.append(Body("Sphere"                 , "sphere"   , False))
bodies[-1].omega[2] = 109.12

# non rotating bodies
bodies.append(Body("BasePlate"              , "bsp"      , False))
bodies.append(Body("LowerSwashPlate"        , "lsp"      , False))
bodies.append(Body("PushRodAt90Deg"         , "prod90"   , False))
bodies.append(Body("PushRodAt180Deg"        , "prod180"  , False))
bodies.append(Body("PushRodAt270Deg"        , "prod270"  , False))
bodies.append(Body("LowerPushHorn"          , "lph"      , False))
bodies.append(Body("UpperPushHorn"          , "uph"      , False))

# Generate BREP file for body
for body in bodies:
    print "GEOHelper: Generating BREP file for body:", body.name
    BREPGenerator.generate(body)

    print "GEOHelper: Generating BREP file for body:", body.name
    SolidProperties.generate(body)
    SolidProperties.writeProps(body)

    print "GEOHelper: Generating BDF file for body:", body.name
    BDFGenerator.generate(body)
