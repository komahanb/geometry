SetFactory("OpenCASCADE");

Include "../Parameters.geo";
Include "../Addon.geo";

///////////////////////////////////////////////////////////////////////
//                    Head rotor 1                                   //
///////////////////////////////////////////////////////////////////////

hcone = 0.5;
xcone = 0.5;
ycone = 0.0;
zcone = 0.0;
dxcone = hcone;
dycone = 0.0;
dzcone = 0.0;
r1cone = 0.5*fuselage_radius;
r2cone = 0.15*fuselage_radius;
acone = 2.0*Pi;
vcone = newv;
Cone(vcone) = {xcone   , ycone  , zcone, 
               -dxcone , dycone , dzcone, 
               r1cone  , r2cone , acone};

// Add an ellipsoid for tail wing
xbase = xcone - hcone/2.0;
ybase = 0.0;
zbase = 0.0;
dx = 0.0;
dy = 0.0;
dz = wing_span/3.0;
chord = wing_chord/5.0;
Call Ellips;
vbladetmp = NewVolume;
out[] = Rotate {{0, 0, 1}, {xbase, ybase, zbase}, Pi/2.0} {Volume{vbladetmp};};
vbladetmp = out[0];
out[] = Rotate {{0, 0, 1}, {xbase, ybase, zbase}, Pi/20.0} {Volume{vbladetmp};};
vbladetmp = out[0];
vblade1 = newv;
BooleanDifference(vblade1) = { Volume{vbladetmp}; Delete; }{ Volume{vcone}; Delete;};

// Rotate vblade1 to make another blade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Volume{vblade1};
};
vblade2 = out[0];

// Specify mesh characteristics
Mesh.CharacteristicLengthExtendFromBoundary = 1; 
Mesh.CharacteristicLengthFactor = 0.25; 
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