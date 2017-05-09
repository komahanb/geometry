// Gmsh project created on Wed May  3 17:53:11 2017
SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";

// Shaft cylinder
vshaft = newv;
Cylinder(vshaft) = {xo, yo, zo, 0, 0, shaft_height, shaft_radius, 2*Pi};
Printf("Created shaft volume (%g)");

// Hub cylinder
vhub = newv;
Cylinder(vhub) = {xo, yo, zo+z_hub, 0, 0, hub_height, hub_radius, 2*Pi};
Printf("Created hub volume (%g)");

vtot = newv;
BooleanUnion(vtot) = { Volume{vshaft}; Delete; }{ Volume{vhub}; Delete; };