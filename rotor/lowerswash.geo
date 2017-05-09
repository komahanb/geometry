//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";

//-------------------------------------------------------------------//
//                    LOWER SWASH PLATE
//-------------------------------------------------------------------//

// create a cylinder

X_cylinder = xo + x_lower_swash;
Y_cylinder = yo + y_lower_swash;
Z_cylinder = zo + z_lower_swash;

vcyl = newv;
Cylinder(vcyl) = {X_cylinder, Y_cylinder, Z_cylinder, 0, 0, lower_swash_height, lower_swash_radius, 2*Pi};

// create a new sphere to cut
X_sphere = xo + x_sphere;
Y_sphere = yo + y_sphere;
Z_sphere = zo + z_sphere;
vspheretmp = newv;
Sphere(vspheretmp) = {X_sphere, Y_sphere, Z_sphere, sphere_radius, -Pi/4, Pi/4, 2*Pi};

vlowerswash = newv;
BooleanDifference(vlowerswash) = { Volume{vcyl}; Delete; }{ Volume{vspheretmp}; Delete; };
Printf("Created lower swash volume (%g)", vlowerswash);
