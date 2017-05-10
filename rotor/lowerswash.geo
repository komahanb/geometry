//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";

aoffset = 0;

//-------------------------------------------------------------------//
// Add a block to the swash plate
//-------------------------------------------------------------------//

dxtmp = base_radius;
dytmp = 1.5*link_length;
dztmp = lower_swash_height;

xtmp = x_lower_swash;
ytmp = y_lower_swash - dytmp/2.0;
ztmp = z_lower_swash;

vblock = newv;
Block(vblock) = {xtmp, ytmp, ztmp, dxtmp, dytmp, dztmp};

//-------------------------------------------------------------------//
// Cut a smaller block out of this
//-------------------------------------------------------------------//

dxtmp = -link_length;
dytmp = -link_length;
dztmp = lower_swash_height;

xtmp = base_radius*Cos(aoffset);
ytmp = base_radius*Sin(aoffset) + link_length/2.0;
ztmp = z_lower_swash;

vsmallblock = newv;
Block(vsmallblock) = {xtmp, ytmp, ztmp, dxtmp, dytmp, dztmp};

vtot = newv;
BooleanDifference(vtot) = { Volume{vblock}; Delete; }{ Volume{vsmallblock}; Delete; };


//------------------------------------------------------------------//
// Cylindrical link
//------------------------------------------------------------------//

xlink = base_radius*Cos(aoffset) - link_length/2.0;
ylink = base_radius*Sin(aoffset) - link_length/2.0;
zlink = z_lower_swash + lower_swash_height/2.0;

hcy = link_length;
rcy = link_radius;

// Add a link along y dir
vlinktmp = newv;
Cylinder(vlinktmp) = {xlink, ylink, zlink, 0, hcy, 0, rcy, 2*Pi};

// create a new sphere to add to the link
vspheretmp = newv;
Sphere(vspheretmp) = {xlink, ylink + link_length/2.0 , zlink, pushrod_sphere_radius, -Pi/2, Pi/2, 2*Pi};
vlink  = newv;
BooleanUnion(vlink) = { Volume{vlinktmp}; Delete;}{ Volume{vspheretmp}; Delete;};

// Add the spherical headed connector to the total volume of the plate
v = newv;
BooleanUnion(v) = { Volume{vtot}; Delete;}{ Volume{vlink}; Delete;};

//v = Fillet{v}{11, 18, 25, 23, 7, 5, 6, 21, 19, 20, 12, 17, 22, 9, 16, 14, 8, 10}{0.0025};
//Printf("newvol %g", v);

//-------------------------------------------------------------------//
//                   MAIN CYLINDRICAL PLATE
//-------------------------------------------------------------------//

vcyl = newv;
Cylinder(vcyl) = {x_lower_swash, y_lower_swash, z_lower_swash, 0, 0, lower_swash_height, lower_swash_radius, 2*Pi};

// Remove the piece separately
vpiece = newv;
BooleanDifference(vpiece) = { Volume{v}; Delete;}{ Volume{vcyl};};

// Now add the piece to the cylinder
vnew = newv;
BooleanUnion(vnew) = { Volume{vcyl}; Delete;}{ Volume{vpiece}; Delete;};

//vnew = Fillet{vnew}{23, 24, 28, 14}{fillet_radius};

out[] = Rotate {{0, 0, 1}, {0, 0, 0}, Pi/2} {
Duplicata { Volume{vnew}; }
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

// Unite all volumes into one
v1 = newv;
BooleanUnion(v1) = { Volume{vconn3}; Delete;}{ Volume{vconn4}; Delete;};
Coherence;

v2 = newv;
BooleanUnion(v2) = { Volume{vnew}; Delete;}{ Volume{vconn2}; Delete;};
Coherence;

vplate = newv;
BooleanUnion(vplate) = { Volume{v1}; Delete;}{ Volume{v2}; Delete;};

// create a new sphere to cut
X_sphere =  x_sphere;
Y_sphere =  y_sphere;
Z_sphere =  z_sphere;
vsp = newv;
Sphere(vsp) = {X_sphere, Y_sphere, Z_sphere, sphere_radius, -Pi/4, Pi/4, 2*Pi};

vlowerswash = newv;
BooleanDifference(vlowerswash) = { Volume{vplate}; Delete; }{ Volume{vsp}; Delete; };
Printf("Created lower swash volume (%g)", vlowerswash);
