// 
SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";

xloc = 0.0;
yloc = 0.0;
zloc = 0.0;

//-------------------------------------------------------------------//
// Create a body cylinder
//-------------------------------------------------------------------//

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
zcy   = zloc + horn_length;

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
zcy   = zloc + horn_length;

vspheretmp = newv;
Sphere(vspheretmp) = {xcy, ycy, zcy, pushrod_sphere_radius, -Pi/2, Pi/2, 2*Pi};
Printf("Punched spherical hole in pushrod = %g", vspheretmp);
v = newv;
BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vspheretmp}; Delete; };

//-------------------------------------------------------------------//
// Create a TAIL cylinder with REVOLUTE cavity
//-------------------------------------------------------------------//


// 1. Add a cylinder of full height and radius

hcy   = 2*horn_base_radius;
rcy   = horn_outer_radius;

xcy   = xloc;
ycy   = yloc - horn_base_radius;
zcy   = zloc;

vtail1 = newv;
Cylinder(vtail1) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created tail pushrod cylinder = %g", vtail1);

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{v}; Delete; }{ Volume{vtail1}; Delete; };
NewVolume = vtot;

// Cut a cylinder of same radius but quarter height moved inside

xcy   = xloc;
ycy   = yloc - horn_base_radius/2.0;
zcy   = zloc;

vtail2 = newv;
Cylinder(vtail2) = {xcy, ycy, zcy, 0, hcy/2.0, 0, rcy, 2*Pi};
Printf("Created tail pushrod cylinder = %g", vtail2);

// Unite the body and head to make the pushrod
vtot2 = newv;
BooleanDifference(vtot2) = { Volume{vtot}; Delete; }{ Volume{vtail2}; Delete; };
NewVolume = vtot2;

// Cut a cylinder of full height but bolt radius
xcy   = xloc;
ycy   = yloc - horn_base_radius;
zcy   = zloc;
rcy   = horn_bolt_radius;

vhole = newv;
Cylinder(vhole) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created tail pushrod cylinder = %g", vhole);

// Unite the body and head to make the pushrod
vfinal = newv;
BooleanDifference(vfinal) = { Volume{vtot2}; Delete; }{ Volume{vhole}; Delete; };
NewVolume = vfinal;
