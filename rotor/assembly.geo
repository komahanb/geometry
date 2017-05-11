//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "naca.geo";
Include "CreateComponents.geo";

//--------------------------------------------------------------------//
//------------------      PUSHRODS   ---------------------------------//
//--------------------------------------------------------------------//

Call CreatePushRod90;
Call CreatePushRod180;
Call CreatePushRod270;

//-------------------------------------------------------------------//
//------------------------ BASEPLATE --------------------------------//
//-------------------------------------------------------------------//

Call CreateBasePlate;

//-------------------------------------------------------------------//
//                         HUB
//-------------------------------------------------------------------//

Call CreateDoubleBladeHub;

//-------------------------------------------------------------------//
//                         SPHERE
//-------------------------------------------------------------------//

// Sphere
X_sphere = xo + x_sphere;
Y_sphere = yo + y_sphere;
Z_sphere = zo + z_sphere;

vspheretmp = newv;
Sphere(vspheretmp) = {X_sphere, Y_sphere, Z_sphere, sphere_radius, -Pi/4, Pi/4, 2*Pi};

// Cut the shaft volume from this sphere
vshafttmp = newv;
Cylinder(vshafttmp) = {xo, yo, zo, 0, 0, shaft_height, shaft_radius, 2*Pi};

vsphere = newv;
BooleanDifference(vsphere) = { Volume{vspheretmp}; Delete; }{ Volume{vshafttmp}; Delete; };
Printf("Created sphere volume (%g)", vsphere);

//-------------------------------------------------------------------//
//                    LOWER SWASH PLATE
//-------------------------------------------------------------------//

Call CreateLowerSwashPlate;

//-------------------------------------------------------------------//
//                    UPPER SWASH PLATE
//-------------------------------------------------------------------//


Call CreateUpperSwashPlate;

//-------------------------------------------------------------------//
//                    ROTOR BLADE
//-------------------------------------------------------------------//

// Create a blade at zero
Call CreateBladeX;

// Create a blade at 180
Call CreateBladeNegativeX;
