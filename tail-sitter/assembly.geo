//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Addon.geo";

// Input parameters
//cone_height = 
//xcone = 
//ycone =
//zcone = 

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
xbase = xcone+ 1.5*hcone;
ybase = 0.0;
zbase = 0.0;
dx = 0.0;
dy = 0.0;
dz = wing_span/2.0;
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