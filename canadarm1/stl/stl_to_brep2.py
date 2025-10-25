import FreeCAD
import Mesh
Mesh.open(u"canadarm-2.stl")

import Part
FreeCAD.getDocument("Unnamed").addObject("Part::Feature","canadarm_2001")
__shape__=Part.Shape()
__shape__.makeShapeFromMesh(FreeCAD.getDocument("Unnamed").getObject("canadarm_2").Mesh.Topology,0.100000)
FreeCAD.getDocument("Unnamed").getObject("canadarm_2001").Shape=__shape__
FreeCAD.getDocument("Unnamed").getObject("canadarm_2001").purgeTouched()
del __shape__

import Part
__s__=App.ActiveDocument.canadarm_2001.Shape
__s__=Part.Solid(__s__)
__o__=App.ActiveDocument.addObject("Part::Feature","canadarm_2001_solid")
__o__.Label="canadarm_2001 (Solid)"
__o__.Shape=__s__
del __s__, __o__
__objs__=[]
__objs__.append(FreeCAD.getDocument("Unnamed").getObject("canadarm_2001_solid"))

import Part
Part.export(__objs__,u"../stl/canadarm-2.brep")
del __objs__
