import sys
sys.path.append("/usr/lib/freecad/lib")
import FreeCAD, Part, Mesh

import Mesh
Mesh.open(u"canadarm-9.stl")

import Part
FreeCAD.getDocument("Unnamed").addObject("Part::Feature","canadarm_9001")
__shape__=Part.Shape()
__shape__.makeShapeFromMesh(FreeCAD.getDocument("Unnamed").getObject("canadarm_9").Mesh.Topology,0.100000)
FreeCAD.getDocument("Unnamed").getObject("canadarm_9001").Shape=__shape__
FreeCAD.getDocument("Unnamed").getObject("canadarm_9001").purgeTouched()
del __shape__

import Part
__s__=App.ActiveDocument.canadarm_9001.Shape
__s__=Part.Solid(__s__)
__o__=App.ActiveDocument.addObject("Part::Feature","canadarm_9001_solid")
__o__.Label="canadarm_9001 (Solid)"
__o__.Shape=__s__
del __s__, __o__
__objs__=[]
__objs__.append(FreeCAD.getDocument("Unnamed").getObject("canadarm_9001_solid"))

import Part
Part.export(__objs__,u"../stl/canadarm-9.brep")
del __objs__
