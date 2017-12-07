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

xbase = 9.0 - chord;
ybase = 0.0;
zbase = 0.0;
// Rotate vtailtmp to 45 degrees
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, -Pi/4.0} {
Volume{vtailtmp};
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
BooleanUnion(vtail3) = { Volume{vtail2}; Delete; }{ Volume{vtail315}; Delete; };

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
