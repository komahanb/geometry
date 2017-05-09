
SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";

//-------------------------------------------------------------------//
//                         SPHERE
//-------------------------------------------------------------------//


// Sphere
X_sphere = xo + x_sphere;
Y_sphere = yo + y_sphere;
Z_sphere = zo + z_sphere;

vsphere = newv;
Sphere(vsphere) = {X_sphere, Y_sphere, Z_sphere, sphere_radius, -Pi/4, Pi/4, 2*Pi};

// Cut the shaft volume from this sphere

// Shaft cylinder
vshaft = newv;
Cylinder(vshaft) = {xo, yo, zo, 0, 0, shaft_height, shaft_radius, 2*Pi};
Printf("Created shaft volume (%g)");

vtot = newv;
BooleanDifference(vtot) = { Volume{vsphere}; Delete; }{ Volume{vshaft}; Delete; };

