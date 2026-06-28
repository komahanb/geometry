SetFactory("OpenCASCADE");

// vsphere = newv;
// Sphere(vsphere) = {0, 0, 0, 0.5, 2*Pi, 2*Pi, 2*Pi};

xbase     = 0;
ybase     = 0;
zbase     = 0;
hcy       = 0.2;
rcy       = 0.025;
vcylinder = newv;
Cylinder(vcylinder) = {xbase, ybase, zbase, hcy, 0, 0, rcy, 2*Pi};

// vunion = newv;
// BooleanUnion(vunion) = { Volume{vsphere}; Delete;}{ Volume{vcylinder}; Delete;};

Physical Surface("cylindrical wall") = {1};
Physical Surface("inlet") = {3};
Physical Surface("outlet") = {2};
Physical Volume("domain") = {1};

// Specify mesh characteristics
//Mesh.CharacteristicLengthExtendFromBoundary = 1; 
//Mesh.CharacteristicLengthFactor = 0.2; 
//Mesh.CharacteristicLengthMin = 0; 
//Mesh.CharacteristicLengthMax = 1.0; 
//Mesh.CharacteristicLengthFromCurvature = 0; 
//Mesh.CharacteristicLengthFromPoints = 1; 
Mesh.Optimize = 1; 
Mesh.SubdivisionAlgorithm = 1; 
Mesh.RecombinationAlgorithm = 1; 
Mesh.RecombineAll = 1; 
Mesh.RemeshAlgorithm = 0; 
Mesh.RemeshParametrization = 0; 
Mesh.RefineSteps = 10; 
Mesh.Smoothing = 5;
Mesh.ElementOrder=1; 
// Mesh.BdfFieldFormat=2; 
// Mesh.Format=31;
// Mesh.SaveAll=1;
Mesh.SaveElementTagType=1;