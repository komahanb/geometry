import os, sys
sys.path.append("/usr/lib/freecad/lib")

import FreeCAD, Part, Mesh

stl_file = "canadarm-5.stl"
brep_file = stl_file.split('.stl')[0] + '.brep'

Mesh.open(stl_file)

dockey = "Unnamed"
objkey = "tmp" #os.path.basename(stl_file).split('.stl')[0]


print objkey

FreeCAD.getDocument(dockey).addObject("Part::Feature", objkey)
__shape__=Part.Shape()

print __shape__

__shape__.makeShapeFromMesh(FreeCAD.getDocument(dockey).getObject(objkey).Mesh.Topology,0.100000)
FreeCAD.getDocument(dockey).getObject(objkey).Shape=__shape__
FreeCAD.getDocument(dockey).getObject(objkey).purgeTouched()
del __shape__
__objs__= []
__objs__.append(FreeCAD.getDocument(dockey).getObject(objkey))
Part.export(__objs__, brep_file)
del __objs__
