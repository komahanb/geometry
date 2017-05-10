//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";

//-------------------------------------------------------------------//
// Add a block to the swash plate
//-------------------------------------------------------------------//

roffset = lower_swash_radius - small ;
aoffset = 0;

dxtmp = base_radius-lower_swash_radius+small/4;
dytmp = 0.35*lower_swash_radius;
dztmp = lower_swash_height;

xtmp = x_lower_swash + lower_swash_radius -small/4;
ytmp = y_lower_swash - dytmp/2.0;
ztmp = z_lower_swash;

vblock = newv;
Block(vblock) = {xtmp, ytmp, ztmp, dxtmp, dytmp, dztmp};

//-------------------------------------------------------------------//
// Cut a smaller block out of this
//-------------------------------------------------------------------//

dxtmp = -base_radius/10.0;
dytmp = 0.35*lower_swash_radius/2.0;
dztmp = lower_swash_height;

xtmp = base_radius;
ytmp = y_lower_swash - dytmp/2.0;
ztmp = z_lower_swash;

vsmallblock = newv;
Block(vsmallblock) = {xtmp, ytmp, ztmp, dxtmp, dytmp, dztmp};

vblocks = newv;
BooleanDifference(vblocks) = { Volume{vblock}; Delete; }{ Volume{vsmallblock}; Delete; };

//------------------------------------------------------------------//
// Cylindrical link
//------------------------------------------------------------------//

aoffset = 0.0;
roffset = 0.9*base_radius;

link_length = 0.10*base_radius;
link_radius = base_height/8.0;

xlink = roffset + link_radius*2.0;
ylink = y_lower_swash - link_length/2.0;
zlink = z_lower_swash + lower_swash_height/2.0;

hcy = base_height;
rcy = inner_base_radius;
Rcy = base_radius;

// Add a link along y dir
vlink = newv;
Cylinder(vlink) = {xlink, ylink, zlink, 0, link_length, 0, link_radius, 2*Pi};

vconn1 = newv;
BooleanUnion(vconn1) = { Volume{vblocks}; Delete;}{ Volume{vlink}; Delete;};

out[] = Rotate {{0, 0, 1}, {0, 0, 0}, Pi/2} {
Duplicata { Volume{vconn1}; }
};
vconn2 = out[0];

out[] = Rotate {{0, 0, 1}, {0, 0, 0}, Pi/2} {
Duplicata { Volume{vconn2}; }
};
vconn3 = out[0];

out[] = Rotate {{0, 0, 1}, {0, 0, 0}, Pi/2} {
Duplicata { Volume{vconn3}; }
};
vconn4 = out[0];

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
