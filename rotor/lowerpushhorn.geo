// 
SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";

xloc = 0.0;
yloc = 0.0;
zloc = 0.0;

// Pushrod at 180 degrees
//-------------------------------------------------------------------//
// Create a body cylinder
//-------------------------------------------------------------------//

xbcy      = xloc;
ybcy      = yloc;
zbcy      = zloc;

hrod      = horn_length;
rrod      = horn_radius;

vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rrod, 2*Pi};
Printf("Created body pushrod cylinder = %g", vbody);

//-------------------------------------------------------------------//
// Create a head cylinder
//-------------------------------------------------------------------//

hcy   = 2*horn_radius;
rcy   = horn_outer_head_radius;

xcy   = xloc;
ycy   = yloc - horn_radius;
zcy   = zloc + horn_length;

vhead = newv;
Cylinder(vhead) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created head pushrod cylinder = %g", vhead);

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

// Punch a cylindrical hole on the head
hcy   = 2*horn_radius;
rcy   = horn_inner_head_radius;
vcyltmp = newv;
Cylinder(vcyltmp) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Punched cylindrical hole in pushrod = %g", vcyltmp);
v = newv;
BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vcyltmp}; Delete; };