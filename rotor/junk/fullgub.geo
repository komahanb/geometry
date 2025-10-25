// Gmsh project created on Wed May  3 17:53:11 2017
SetFactory("OpenCASCADE");

Include "parameters.geo";

// Shaft cylinder
Cylinder(1) = {xo, yo, zo, 0, 0, shaft_height, shaft_radius, 2*Pi};

// Baseplate cylinder
Cylinder(2) = {xo, yo, zo, 0, 0, base_height, base_radius, 2*Pi};

// Lower swash plate cylinder
Cylinder(3) = {xo, yo, zo+z_lower_swash, 0, 0, lower_swash_height, lower_swash_radius, 2*Pi};

// Upper swash plate cylinder
Cylinder(4) = {xo, yo, zo+z_upper_swash, 0, 0, upper_swash_height, upper_swash_radius, 2*Pi};

// Hub cylinder
Cylinder(5) = {xo, yo, zo+z_hub, 0, 0, hub_height, hub_radius, 2*Pi};

// Sphere
Sphere(6) = {xo, yo, zo+z_sphere, sphere_radius, -Pi/4, Pi/4, 2*Pi};

// Connector cylinder
xc = xo ;
yc = yo ;
zc = z_hub + hub_height/2.0 ;
dx = (conn_length)*Cos(conn1_angular_pos);
dy = (conn_length)*Sin(conn1_angular_pos);
dz = 0;
Cylinder(7) = {xc, yc, zc, dx, dy, dz, conn_radius, 2*Pi};
