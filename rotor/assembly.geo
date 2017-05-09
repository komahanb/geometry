//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";

// Pushrod at 90 degrees
aoffset = Pi/2.0;
roffset = 0.85*base_radius;
xbcy = x_base + roffset*Cos(aoffset);
ybcy = y_base + roffset*Sin(aoffset);
zbcy = z_base;
hrod = 0.4*shaft_height;
rbase_rod = pushrod_base_radius;
Rhead_rod = pushrod_head_radius;
Call PushRodX;

// Pushrod at 180 degrees
aoffset = Pi;
roffset = 0.85*base_radius;
xbcy = x_base + roffset*Cos(aoffset);
ybcy = y_base + roffset*Sin(aoffset);
zbcy = z_base;
hrod = 0.4*shaft_height;
rbase_rod = pushrod_base_radius;
Rhead_rod = pushrod_head_radius;
Call PushRodY;

// Pushrod at 270 degrees
aoffset = 3.0*Pi/2.0;
roffset = 0.85*base_radius;
xbcy = x_base + roffset*Cos(aoffset);
ybcy = y_base + roffset*Sin(aoffset);
zbcy = z_base;
hrod = 0.4*shaft_height;
rbase_rod = pushrod_base_radius;
Rhead_rod = pushrod_head_radius;
Call PushRodX;

// Create the hollow cylinder for main base plate
xcy = x_base;
ycy = y_base;
zcy = z_base;
hcy = base_height;
rcy = inner_base_radius;
Rcy = base_radius;
angle = 2*Pi;
Call HollowCylinderZ;
Printf("Baseplate volume is (%g)", NewVolume);

// Add push rod hole at 90 degrees
aoffset = Pi/2.0;
roffset = 0.85*base_radius;
baseplate_vnum = NewVolume;
Call AddPushRodHole;
Printf("Baseplate volume is (%g)", NewVolume);

// Add push rod hole at 180 degrees
aoffset = Pi;
roffset = 0.85*base_radius;
baseplate_vnum = NewVolume;
Call AddPushRodHole;
Printf("Baseplate volume is (%g)", NewVolume);

// Add push rod hole at 270 degrees
aoffset = 3.0*Pi/2.0;
roffset = 0.85*base_radius;
baseplate_vnum = NewVolume;
Call AddPushRodHole;
Printf("Baseplate volume is (%g)", NewVolume);

// Create a block volume to be cut from the base plate
aoffset = 0.0;
roffset = 0.9*base_radius;
baseplate_vnum = NewVolume;
Call CutBlock;
Printf("Baseplate volume is (%g)", NewVolume);

//-------------------------------------------------------------------//
//                         HUB
//-------------------------------------------------------------------//

// Shaft cylinder
vshafttmp = newv;
Cylinder(vshafttmp) = {xo, yo, zo, 0, 0, shaft_height, shaft_radius, 2*Pi};

// Hub cylinder
vhubtmp = newv;
Cylinder(vhubtmp) = {xo, yo, zo+z_hub, 0, 0, hub_height, hub_radius, 2*Pi};

vhub = newv;
BooleanUnion(vhub) = { Volume{vshafttmp}; Delete; }{ Volume{vhubtmp}; Delete; };
Printf("Created hub volume (%g)", vhub);


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
BooleanDifference(vlowerswash) = { Volume{vcyl}; Delete; }{ Volume{vspheretmp}; Delete;};
Printf("Created lower swash volume (%g)", vlowerswash);

//-------------------------------------------------------------------//
//                    LOWER SWASH PLATE
//-------------------------------------------------------------------//

// create a cylinder

X_cylinder = xo + x_upper_swash;
Y_cylinder = yo + y_upper_swash;
Z_cylinder = zo + z_upper_swash;

vcyl = newv;
Cylinder(vcyl) = {X_cylinder, Y_cylinder, Z_cylinder, 0, 0, upper_swash_height, upper_swash_radius, 2*Pi};

// create a new sphere to cut
X_sphere = xo + x_sphere;
Y_sphere = yo + y_sphere;
Z_sphere = zo + z_sphere;
vspheretmp = newv;
Sphere(vspheretmp) = {X_sphere, Y_sphere, Z_sphere, sphere_radius, -Pi/4, Pi/4, 2*Pi};

vupperswash = newv;
BooleanDifference(vupperswash) = { Volume{vcyl}; Delete; }{ Volume{vspheretmp}; Delete;};
Printf("Created upper swash volume (%g)", vupperswash);