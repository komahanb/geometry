// Gmsh project created on Wed May  3 17:53:11 2017
SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";

// Shaft cylinder
vshaft = newv;
Cylinder(vshaft) = {x_hub, y_hub, z_hub, 0, 0, shaft_height-hub_height, shaft_radius, 2*Pi};
Printf("Created shaft volume (%g)", vshaft);

// Hub cylinder
vhub = newv;
Cylinder(vhub) = {x_hub, y_hub, z_hub+shaft_height-hub_height, 0, 0, hub_height, hub_radius, 2*Pi};
Printf("Created hub volume (%g)", vhub);

// 
vtot = newv;
BooleanUnion(vtot) = { Volume{vshaft}; Delete; }{ Volume{vhub}; Delete; };
Printf("Combined shaft and hub volume (%g)", vtot);

//--------------------------------------------------------------------//
// Create a hub connector body on right
//--------------------------------------------------------------------//

xhconn = x_hub;
yhconn = y_hub;
zhconn = z_hub + shaft_height - hub_height/2.0 ;
dx = upper_swash_radius;
dy = 0;
dz = 0;
vhubconn = newv;
Cylinder(vhubconn) = {xhconn, yhconn, zhconn, dx, dy, dz, blade_conn_radius, 2*Pi};

vfinal = newv;
BooleanUnion(vfinal) = { Volume{vtot}; Delete; }{ Volume{vhubconn}; Delete; };

//--------------------------------------------------------------------//
// Create a hub connector body on the left
//--------------------------------------------------------------------//

xhconn = x_hub;
yhconn = y_hub;
zhconn = z_hub + shaft_height - hub_height/2.0 ;
dx = -upper_swash_radius;
dy = 0;
dz = 0;
vhubconn2 = newv;
Cylinder(vhubconn2) = {xhconn, yhconn, zhconn, dx, dy, dz, blade_conn_radius, 2*Pi};

vfinal2 = newv;
BooleanUnion(vfinal2) = { Volume{vfinal}; Delete; }{ Volume{vhubconn2}; Delete; };