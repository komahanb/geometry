// 
SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";

// Infer this point geometrically
xloc = 0.305479353034;
yloc = 0.0992562585932;
zloc = 0.43;

// Create a spherical body of height upto half of the hub

xbcy = xloc;
ybcy = yloc;
zbcy = zloc;

hrod = horn_length;
rrod = 0.99*horn_base_radius;

vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rrod, 2*Pi};
Printf("Created body pushrod cylinder = %g", vbody);

//-------------------------------------------------------------------//
// Create a HEAD cylinder with spherical cavity
//-------------------------------------------------------------------//

hcy   = 2*horn_base_radius;
rcy   = horn_outer_radius;

xcy   = xloc;
ycy   = yloc - horn_base_radius;
zcy   = zloc;

vhead = newv;
Cylinder(vhead) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created head pushrod cylinder = %g", vhead);

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

// Punch a spherical hole on the head
xcy   = xloc;
ycy   = yloc;
zcy   = zloc;

vspheretmp = newv;
Sphere(vspheretmp) = {xcy, ycy, zcy, pushrod_sphere_radius, -Pi/2, Pi/2, 2*Pi};
Printf("Punched spherical hole in pushrod = %g", vspheretmp);
v = newv;
BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vspheretmp}; Delete; };


