import sys
sys.path.append("/usr/lib/freecad/lib")
import FreeCAD, Part, Mesh

Mesh.open(u"canadarm-9.stl")
FreeCAD.getDocument("Unnamed").addObject("Part::Feature","canadarm_9001")
__shape__=Part.Shape()
__shape__.makeShapeFromMesh(FreeCAD.getDocument("Unnamed").getObject("canadarm_9").Mesh.Topology,0.001)
FreeCAD.getDocument("Unnamed").getObject("canadarm_9001").Shape=__shape__
FreeCAD.getDocument("Unnamed").getObject("canadarm_9001").purgeTouched()
del __shape__
__objs__=[]
__objs__.append(FreeCAD.getDocument("Unnamed").getObject("canadarm_9001"))
Part.export(__objs__,u"../brep/canadarm-9.brep")
del __objs__
