SetFactory("OpenCASCADE");

Include "../Parameters.geo";
Include "../Addon.geo";

///////////////////////////////////////////////////////////////////////
//                    Head rotor 2                                   //
///////////////////////////////////////////////////////////////////////

// Add the cone for rotor assembly
hcone  = 0.5;
xcone  = 1.0;
ycone  = 0.0;
zcone  = 0.0;
dxcone = hcone;
dycone = 0.0;
dzcone = 0.0;
r1cone = fuselage_radius;
r2cone = 0.5*fuselage_radius;
acone  = 2.0*Pi;
vcone  = newv;
Cone(vcone) = {xcone, ycone, zcone, 
               -dxcone, dycone, dzcone, 
               r1cone, r2cone, acone};

// Specify mesh characteristics
Mesh.CharacteristicLengthExtendFromBoundary = 1; 
Mesh.CharacteristicLengthFactor = 0.5; 
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