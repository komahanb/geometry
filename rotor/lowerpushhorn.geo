// 
SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";


// Create a cylinder with length horn_length and positioned on top of
// the cylindrical cap made on the baseplate punched link

// These are inputs
xpos = 0.0;
ypos = 0.0;
zpos = 0.0;
radius = horn_radius;
height = horn_length;

// Create a cylinder
vbody = newv;
Cylinder(vbody) = {xpos, ypos, zpos, 0, height, 0, radius, 2*Pi};

// Add a full cylinder at the bottom
xpos = xpos - horn_radius;
radius = horn_outer_tail_radius;
height = 2*horn_radius;
vtail = newv;
Cylinder(vtail) = {xpos, ypos, zpos, height, 0, 0, radius, 2*Pi};

// Unite the body with main cylinder
v = newv;
BooleanUnion(v) = { Volume{vbody}; Delete;}{ Volume{vtail}; Delete;};

// Cut out a smaller cylinder at the bottom
radius = horn_inner_tail_radius;
height = 2*horn_radius;
vtailcut = newv;
Cylinder(vtailcut) = {xpos, ypos, zpos, height, 0, 0, radius, 2*Pi};
vhorn = newv;
BooleanDifference(vhorn) = { Volume{v}; Delete; }{ Volume{vtailcut}; Delete; };

// Add a one-third cylinder on top

// Cut out a bolt hole of radius




