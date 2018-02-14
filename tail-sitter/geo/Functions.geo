//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");
Include "../Parameters.geo";
Include "../Addon.geo";

xbase_assembly = 10.0; 
ybase_assembly = 0.0;
zbase_assembly = wing_span/4.0;
assembly_pole_height = 2.5;
assembly_cone_height = 0.25;
assembly_small_cone_radius = 0.10*fuselage_radius;
assembly_large_cone_radius = 0.25*fuselage_radius;
blade_span = wing_span/8.0;
blade_chord = wing_chord/8.0;
assembly_angle_of_attack = Pi/20.0;

// Add the tail assembly
xcone = xbase_assembly - assembly_pole_height;
ycone = ybase_assembly;
zcone = zbase_assembly;
dxcone = assembly_cone_height;
dycone = 0.0;
dzcone = 0.0;
r1cone = assembly_large_cone_radius;
r2cone = assembly_small_cone_radius;
acone = 2.0*Pi;
vcone = newv;
Cone(vcone) = {xcone   , ycone  , zcone, 
               -dxcone , dycone , dzcone, 
               r1cone  , r2cone , acone};

// Add an ellipsoid for tail wing
xbase_assembly = xcone - assembly_cone_height/2.0;
xbase = xbase_assembly;
ybase = ybase_assembly;
zbase = zbase_assembly;

dx = 0.0;
dy = 0.0;
dz = blade_span;
chord = blade_chord;
Call Ellips;
vtailbladetmp = NewVolume;
out[] = Rotate {{0, 0, 1}, {xbase_assembly, ybase_assembly, zbase_assembly}, Pi/2.0} {Volume{vtailbladetmp};};
vtailbladetmp = out[0];
out[] = Rotate {{0, 0, 1}, {xbase_assembly, ybase_assembly, zbase_assembly}, assembly_angle_of_attack} {Volume{vtailbladetmp};};
vtailbladetmp = out[0];
vtailblade1 = newv;
BooleanDifference(vtailblade1) = { Volume{vtailbladetmp}; Delete; }{ Volume{vcone}; };




















// Add an ellipsoid for tail wing
xbase_assembly = xcone - assembly_cone_height/2.0;
xbase = xbase_assembly;
ybase = ybase_assembly;
zbase = zbase_assembly;

dx = 0.0;
dy = 0.0;
dz = blade_span;
chord = blade_chord;
Call Ellips;
vtailbladetmp = NewVolume;
out[] = Rotate {{0, 0, 1}, {xbase_assembly, ybase_assembly, zbase_assembly}, Pi/2.0} {Volume{vtailbladetmp};};
vtailbladetmp = out[0];
out[] = Rotate {{0, 0, 1}, {xbase_assembly, ybase_assembly, zbase_assembly}, assembly_angle_of_attack} {Volume{vtailbladetmp};};
vtailbladetmp = out[0];
vtailblade1 = newv;
BooleanDifference(vtailblade1) = { Volume{vtailbladetmp}; Delete; }{ Volume{vcone}; };






// Rotate vtailblade1 to make another tailblade
out[] = Rotate {{1, 0, 0}, {xbase_assembly, ybase_assembly, zbase_assembly}, Pi/2.0} {
Duplicata { Volume{vtailblade1}; }
};
vtailblade2 = out[0];
// Rotate vtailblade2 to make another tailblade
out[] = Rotate {{1, 0, 0}, {xbase_assembly, ybase_assembly, zbase_assembly}, Pi/2.0} {
Duplicata { Volume{vtailblade2}; }
};
vtailblade3 = out[0];
// Rotate vtailblade3 to make another tailblade
out[] = Rotate {{1, 0, 0}, {xbase_assembly, ybase_assembly, zbase_assembly}, Pi/2.0} {
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
