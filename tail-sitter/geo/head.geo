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
BooleanDifference(vblade1) = { Volume{vbladetmp}; Delete; }{ Volume{vcone}; };

// Rotate vblade1 to make another blade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata { Volume{vblade1}; }
};
vblade2 = out[0];

// Rotate vblade2 to make another blade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata { Volume{vblade2}; }
};
vblade3 = out[0];

// Rotate vblade3 to make another blade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata { Volume{vblade3}; }
};
vblade4 = out[0];

// Combine all volumes with the cone
vtmp = newv;
BooleanUnion(vtmp) = { Volume{vblade1}; Delete;}{ Volume{vcone}; Delete;};

vtmp1 = newv;
BooleanUnion(vtmp1) = { Volume{vtmp}; Delete;}{ Volume{vblade2}; Delete;};

vtmp2 = newv;
BooleanUnion(vtmp2) = { Volume{vtmp1}; Delete;}{ Volume{vblade3}; Delete;};

vtmp3 = newv;
BooleanUnion(vtmp3) = { Volume{vtmp2}; Delete;}{ Volume{vblade4}; Delete;};
vheadrotor = vtmp3;

// Rotate vblade3 to make another blade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/4.0} {
Volume{vheadrotor};
};
vheadrotor = out[0];

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

// Add an ellipsoid for tail wing
chord = wing_chord/5.0;
xbase = xcone - hcone/2.0;
ybase = 0.0;
zbase = 0.0;
dx = 0.0;
dy = 0.0;
dz = wing_span/3.0;
Call Ellips;
vbladetmp = NewVolume;
out[] = Rotate {{0, 0, 1}, {xbase, ybase, zbase}, Pi/2.0} {
Volume{vbladetmp};
};
vbladetmp = out[0];
out[] = Rotate {{0, 0, 1}, {xbase, ybase, zbase}, Pi/20.0} {
Volume{vbladetmp};
};
vbladetmp = out[0];
vblade1 = newv;
BooleanDifference(vblade1) = { Volume{vbladetmp}; Delete; } { Volume{vcone}; };

// Rotate vblade1 to make another blade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata { Volume{vblade1}; }
};
vblade2 = out[0];

// Rotate vblade2 to make another blade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata { Volume{vblade2}; }
};
vblade3 = out[0];

// Rotate vblade3 to make another blade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata { Volume{vblade3}; }
};
vblade4 = out[0];

// Combine all volumes with the cone
vtmp = newv;
BooleanUnion(vtmp) = { Volume{vblade1}; Delete;}{ Volume{vcone}; Delete;};

vtmp1 = newv;
BooleanUnion(vtmp1) = { Volume{vtmp}; Delete;}{ Volume{vblade2}; Delete;};

vtmp2 = newv;
BooleanUnion(vtmp2) = { Volume{vtmp1}; Delete;}{ Volume{vblade3}; Delete;};

vtmp3 = newv;
BooleanUnion(vtmp3) = { Volume{vtmp2}; Delete;}{ Volume{vblade4}; Delete;};
vheadrotor2 = vtmp3;

// combine two head pices
vhead = newv;
BooleanUnion(vhead) = { Volume{vheadrotor2}; Delete;}{ Volume{vheadrotor}; Delete;};


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
