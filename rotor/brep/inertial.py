# Import lib
import sys
sys.path.append("/usr/lib/freecad/lib")

import numpy as np

# Import CAD
import FreeCAD
import Part

# Problem parameters
Density = 2500.0
Omega = 109.12
Grav = -9.81
vz = 0.0
mesh_type = 1

def writeProps(brep, name):
    """
    Write the inertial properties and initial conditions to a file
    """
    Part.open(brep)
    key = brep.split('.')[0]
    App.ActiveDocument = App.getDocument(key)
    doc = App.getDocument(key)
    doc.recompute()
    
    shape = doc.getObject(key).Shape

    # Retrieve the solid from shape
    solid = shape.Solids[0]
    J = solid.MatrixOfInertia
    
    print "Creating property file", key + '.dat'
    
    c = [0.0, 0.0, 0.0]
    Jmat = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    xcm = [0.0, 0.0, 0.0]
    
    CTMP = [solid.StaticMoments[0], solid.StaticMoments[1], solid.StaticMoments[2]]
    JTMP = [J.A11, J.A12, J.A13, J.A22, J. A23, J.A33]
    xcmtmp = [solid.CenterOfMass.x, solid.CenterOfMass.y, solid.CenterOfMass.z]
    
    for i in xrange(3):
        #if abs(CTMP[i]) > 1.0e-16:        
        if abs(xcmtmp[i]) > 1.0e-16:
            c[i] = CTMP[i]
            xcm[i] = xcmtmp[i]

    for i in xrange(6):
        if abs(JTMP[i]) > 1.0e-16:
            Jmat[i] = JTMP[i]

    # Assert the equivalence of xcg and c/volume
    assert(np.allclose(np.array(xcm), np.array(c)/solid.Volume) , 1)
            
    fp = open(key + '.dat', 'w')   
    fp.write('name %s\n' % name)
    fp.write('density %s\n' % Density)
    fp.write('volume %s\n' % solid.Volume)
    fp.write('c %s %s %s\n' % (c[0], c[1], c[2]))
    fp.write('J %s %s %s %s %s %s\n' % (Jmat[0], Jmat[1], Jmat[2], Jmat[3], Jmat[4], Jmat[5]))
    fp.write('xcg %s %s %s\n' % (xcm[0], xcm[1], xcm[2]))
    fp.write('vel %s %s %s\n' % (0.0,0.0,vz))
    fp.write('omega %s %s %s\n' % (0.0,0.0,Omega))
    fp.write('grav %s %s %s\n' % (0.0,0.0,Grav))
    fp.write('mesh %s %s\n' % (key+'.bdf',mesh_type))
    fp.close()

#print "orientation=", shape.Orientation
#print "xcg =", solid.CenterOfMass.x, solid.CenterOfMass.y, solid.CenterOfMass.z
#print "J=", solid.MatrixOfInertia.A11
#print np.array(solid.StaticMoments)
#myshape.PrincipalProperties -> dictionary
#myshape.getRadiusOfGyration(pnt, dir)

# Write all the rotating parts
writeProps("bcap0.brep", "BladeCapAt0Deg")
writeProps("bcap180.brep", "BladeCapAt180Deg")
writeProps("blade0.brep", "BladeAt0Deg")
writeProps("blade180.brep", "BladeAt180Deg")
writeProps("hub.brep", "Hub")
writeProps("lpl30.brep", "LowerPitchLinkAt30Deg")
writeProps("lpl210.brep", "LowerPitchLinkAt210Deg")
writeProps("upl30.brep", "UpperPitchLinkAt30Deg")
writeProps("upl210.brep", "UpperPitchLinkAt210Deg")
writeProps("usp.brep", "UpperSwashPlate")

# Write all the non rotating parts
Omega=0.0
writeProps("bsp.brep", "BasePlate")

# Components with initial velocity in z-direction
vz = 0.5

writeProps("sphere.brep", "Sphere")
writeProps("lph.brep", "LowerPushHorn")
writeProps("uph.brep", "UpperPushHorn")
writeProps("lsp.brep", "LowerSwashPlate")

writeProps("prod90.brep", "PushRodAt90Deg")
writeProps("prod180.brep", "PushRodAt180Deg")
writeProps("prod270.brep", "PushRodAt270Deg")
    
