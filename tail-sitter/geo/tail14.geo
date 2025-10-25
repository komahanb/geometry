//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "../Parameters.geo";
Include "../Addon.geo";

///////////////////////////////////////////////////////////////////////
//                Empennage                                          //  
///////////////////////////////////////////////////////////////////////

// Add the tail cone and empennage
htcone  = 1.0;
xtcone  = 8.0;
ytcone  = 0.0;
ztcone  = 0.0;
dxtcone = htcone;
dytcone = 0.0;
dztcone = 0.0;
r1tcone = fuselage_radius;
r2tcone = 0.3*fuselage_radius;
atcone  = 2.0*Pi;
vtcone  = newv;
Cone(vtcone) = {xtcone, ytcone, ztcone, 
                dxtcone, dytcone, dztcone, 
                r1tcone, r2tcone, atcone};
// Add an ellipsoid for tail wing
chord = wing_chord/2.0;
xbase = 9.0 - chord;
ybase = 0.0;
zbase = 0.0;
dx = 0.0;
dy = 0.0;
dz = wing_span/4.0;
Call Ellips;
vtbladetmp = NewVolume;
vtblade = newv;
BooleanDifference(vtblade) = { Volume{vtbladetmp}; Delete; } { Volume{vtcone}; };
// Add a cylinder to hold the rotor and balance
height = 2.5;
xtmp = 10.0; 
ytmp = 0.0;
ztmp = wing_span/4.0;
dx = height;
dy = 0.0;
dz = 0.0;
radius = 0.15*tail_chord;
vtmpcyl = newv;
Cylinder(vtmpcyl) = {xtmp, ytmp, ztmp,
                  -dx, dy, dz,
                  radius, 
                  2.0*Pi};

// merge tail piece with tail assembly
vtailtmp = newv;
BooleanUnion(vtailtmp) = { Volume{vtblade}; Delete; }{ Volume{vtmpcyl}; Delete; };

// Add the tail assembly
hcone = 0.25;
xcone = xtmp - height;
ycone = ytmp;
zcone = ztmp;
dxcone = hcone;
dycone = 0.0;
dzcone = 0.0;
r1cone = 0.25*fuselage_radius;
r2cone = 0.10*fuselage_radius;
acone = 2.0*Pi;
vcone = newv;
Cone(vcone) = {xcone   , ycone  , zcone, 
               -dxcone , dycone , dzcone, 
               r1cone  , r2cone , acone};

// Add an ellipsoid for tail wing
xbase = xcone - hcone/2.0;
ybase = ytmp;
zbase = ztmp;
dx = 0.0;
dy = 0.0;
dz = wing_span/8.0;
chord = wing_chord/8.0;
Call Ellips;
vtailbladetmp = NewVolume;
out[] = Rotate {{0, 0, 1}, {xbase, ybase, zbase}, Pi/2.0} {Volume{vtailbladetmp};};
vtailbladetmp = out[0];
out[] = Rotate {{0, 0, 1}, {xbase, ybase, zbase}, Pi/20.0} {Volume{vtailbladetmp};};
vtailbladetmp = out[0];
vtailblade1 = newv;
BooleanDifference(vtailblade1) = { Volume{vtailbladetmp}; Delete; }{ Volume{vcone}; };
// Rotate vtailblade1 to make another tailblade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata { Volume{vtailblade1}; }
};
vtailblade2 = out[0];
// Rotate vtailblade2 to make another tailblade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata { Volume{vtailblade2}; }
};
vtailblade3 = out[0];
// Rotate vtailblade3 to make another tailblade
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata { Volume{vtailblade3}; }
};
vtailblade4 = out[0];
// Combine all volumes with the cone
vtmp = newv;
BooleanUnion(vtmp) = { Volume{vtailblade1}; Delete;}{ Volume{vcone}; Delete;};
vtmp1 = newv;
BooleanUnion(vtmp1) = { Volume{vtmp}; Delete;}{ Volume{vtailblade2}; Delete;};
vtmp2 = newv;
BooleanUnion(vtmp2) = { Volume{vtmp1}; Delete;}{ Volume{vtailblade3}; Delete;};
vtmp3 = newv;
BooleanUnion(vtmp3) = { Volume{vtmp2}; Delete;}{ Volume{vtailblade4}; Delete;};
vtassembly = vtmp3;


// merge the tail assembly with current tail
vtailtmp1 = newv;
BooleanUnion(vtailtmp1) = { Volume{vtassembly}; Delete; }{ Volume{vtailtmp}; Delete; };



xbase = 9.0 - chord;
ybase = 0.0;
zbase = 0.0;
// Rotate vtailtmp to 45 degrees
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, -Pi/4.0} {
Volume{vtailtmp1};
};
vtail45 = out[0];

//// Tail at 135 degrees
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata{ Volume{vtail45}; }
};
vtail135 = out[0];

// Tail at 225 degrees
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata{ Volume{vtail135}; }
};
vtail225 = out[0];

// Tail at 315 degrees
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Duplicata{ Volume{vtail225}; }
};
vtail315 = out[0];

vtail = newv;
BooleanUnion(vtail) = { Volume{vtail45}; Delete; }{ Volume{vtcone}; Delete; };

vtail1 = newv;
BooleanUnion(vtail1) = { Volume{vtail}; Delete; }{ Volume{vtail135}; Delete; };

vtail2 = newv;
BooleanUnion(vtail2) = { Volume{vtail1}; Delete; }{ Volume{vtail225}; Delete; };

vtail3 = newv;
BooleanUnion(vtail3) = { Volume{vtail2}; Delete; }{ Volume{vtail315}; Delete; };\

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
