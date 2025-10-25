import numpy as np
from naca import naca, Display
import pygmsh

# Generate NACA points
X, Y = naca("2012", 6, True, True)
npts = len(X)
points = np.array([X, [0.0]*npts, Y])

# Scale the points for HART-based geometry
points = 0.121*points
span = 2.0
root_cutout = 0.44

# gmsh geometry object
geom = pygmsh.built_in.Geometry()

######################################################################
# Create points
######################################################################

lcar = 0.01 #05
gpoints = [geom.add_point(points[:,k], lcar) for k in xrange(npts)]
for p in gpoints:
    print p.id
    
######################################################################
# Create lines
######################################################################

lines = []
lines.append(geom.add_line(gpoints[-1], gpoints[0]))
spline = geom.add_spline(gpoints[0:6])
lines.append(spline)
spline = geom.add_spline(gpoints[5:8])
lines.append(spline)
spline = geom.add_spline(gpoints[7:])
lines.append(spline)
for l in lines:
    print l.id

######################################################################
# Create lineloop
######################################################################

ll = geom.add_line_loop((lines))
print ll.id

######################################################################
# Create surface
######################################################################

surface = geom.add_plane_surface(ll, holes=[])

######################################################################
# Create volume by extruding alone y-axis
######################################################################

axis = [0, span-root_cutout, 0]
geom.extrude(
    surface,
    translation_axis=axis,
    point_on_axis=[0, 0, 0])

######################################################################
# Write .geo file
######################################################################
code = ['SetFactory("OpenCASCADE");\n']
code.append(geom.get_code())
file = open('blunt_blade.geo','w') 
for line in code:    
    file.write(line) 
file.close() 


