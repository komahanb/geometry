//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";

Call CreateLowerSwashPlate;

aoffset = 0;
uswash_outer_radius = base_radius - link_length;

//-------------------------------------------------------------------//
// Add a block to the swash plate
//-------------------------------------------------------------------//

dxtmp = uswash_outer_radius;
dytmp = 1.5*link_length;
dztmp = upper_swash_height;

xtmp = x_upper_swash;
ytmp = y_upper_swash - dytmp/2.0;
ztmp = z_upper_swash;

vblock = newv;
Block(vblock) = {xtmp, ytmp, ztmp, dxtmp, dytmp, dztmp};

//-------------------------------------------------------------------//
// Cut a smaller block out of this
//-------------------------------------------------------------------//

dxtmp = -link_length;
dytmp = -link_length;
dztmp = upper_swash_height;

xtmp = uswash_outer_radius*Cos(aoffset);
ytmp = uswash_outer_radius*Sin(aoffset) + link_length/2.0;
ztmp = z_upper_swash;

vsmallblock = newv;
Block(vsmallblock) = {xtmp, ytmp, ztmp, dxtmp, dytmp, dztmp};

vtot = newv;
BooleanDifference(vtot) = { Volume{vblock}; Delete; }{ Volume{vsmallblock}; Delete; };


//------------------------------------------------------------------//
// Cylindrical link
//------------------------------------------------------------------//

xlink = uswash_outer_radius*Cos(aoffset) - link_length/2.0;
ylink = uswash_outer_radius*Sin(aoffset) - link_length/2.0;
zlink = z_upper_swash + upper_swash_height/2.0;

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
Cylinder(vcyl) = {x_upper_swash, y_upper_swash, z_upper_swash, 0, 0, upper_swash_height, upper_swash_radius, 2*Pi};

// Remove the piece separately
vpiece = newv;
BooleanDifference(vpiece) = { Volume{v}; Delete;}{ Volume{vcyl};};

// Now add the piece to the cylinder
vnew = newv;
BooleanUnion(vnew) = { Volume{vcyl}; Delete;}{ Volume{vpiece}; Delete;};

out[] = Rotate {{0, 0, 1}, {0, 0, 0}, Pi} {
Duplicata { Volume{vnew}; }
};
vconn2 = out[0];

//out[] = Rotate {{0, 0, 1}, {0, 0, 0}, 2.0*Pi/3.0} {
//Duplicata { Volume{vconn2}; }
//};
//vconn3 = out[0];

// Unite all volumes into one
vplate = newv;
BooleanUnion(vplate) = { Volume{vnew}; Delete;}{ Volume{vconn2}; Delete;};
Coherence;

// create a new sphere to cut
X_sphere =  x_sphere;
Y_sphere =  y_sphere;
Z_sphere =  z_sphere;
vsp = newv;
Sphere(vsp) = {X_sphere, Y_sphere, Z_sphere, sphere_radius, -Pi/4, Pi/4, 2*Pi};

vupperswash = newv;
BooleanDifference(vupperswash) = { Volume{vplate}; Delete; }{ Volume{vsp}; Delete; };
Printf("Created upper swash volume (%g)", vupperswash);


