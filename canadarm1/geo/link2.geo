SetFactory("OpenCASCADE");

// Include the parametrized inputs for geometry
Include "../Parameters.geo";

///////////////////////////////////////////////////////////////////////
//                Cylindrical Link 2   (y, flexible)                 //  
///////////////////////////////////////////////////////////////////////

xtmp   = xbaselink2;
ytmp   = ybaselink2;
ztmp   = zbaselink2;
vtmp   = newv;
dx     = length_link2;
dy     = 0.0;
dz     = 0.0;
radius = radius_link2;
Cylinder(vtmp) = {xtmp, ytmp, ztmp,
                  dx, dy, dz,
                  radius,
                  2.0*Pi};

// Specify mesh characteristics
Mesh.CharacteristicLengthExtendFromBoundary = 1; 
Mesh.CharacteristicLengthFactor = 0.1; 
Mesh.CharacteristicLengthMin = 0; 
Mesh.CharacteristicLengthMax = 1.0; 
Mesh.CharacteristicLengthFromCurvature = 0; 
Mesh.CharacteristicLengthFromPoints = 1; 
Mesh.Optimize = 1; 
Mesh.SubdivisionAlgorithm = 1; 
Mesh.RecombinationAlgorithm = 1; 
Mesh.RecombineAll = 1; 
Mesh.RemeshAlgorithm = 0; 
Mesh.RemeshParametrization = 0; 
Mesh.RefineSteps = 10; 
Mesh.Smoothing = 5;
Mesh.ElementOrder=2; 
Mesh.BdfFieldFormat=2; 
Mesh.Format=31; 
Mesh.SaveElementTagType=1;
