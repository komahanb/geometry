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
out[] = Rotate {{1, 0, 0}, {0,0,0}, Pi/2.0 + Pi/4.0} {
Volume{vcone};
};
vcone = out[0];
