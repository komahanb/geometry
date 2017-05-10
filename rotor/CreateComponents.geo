Function CreateLowerSwashPlate
//
//-------------------------------------------------------------------//
// Add a block to the swash plate
//-------------------------------------------------------------------//

roffset = lower_swash_radius - small ;
aoffset = 0;

dxtmp = base_radius-lower_swash_radius+small/2;
dytmp = 0.5*lower_swash_radius;
dztmp = lower_swash_height;

xtmp = x_lower_swash + lower_swash_radius -small/2;
ytmp = y_lower_swash - dytmp/2.0;
ztmp = z_lower_swash;

vblock = newv;
Block(vblock) = {xtmp, ytmp, ztmp, dxtmp, dytmp, dztmp};

//-------------------------------------------------------------------//
// Cut a smaller block out of this
//-------------------------------------------------------------------//

dxtmp = -base_radius/10.0;
dytmp = link_length;
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

vtmp1 = newv;
BooleanUnion(vtmp1) = { Volume{vlowerswash}; Delete;}{ Volume{vconn1}; Delete;};

vtmp2 = newv;
BooleanUnion(vtmp2) = { Volume{vtmp1}; Delete;}{ Volume{vconn2}; Delete;};

vtmp3 = newv;
BooleanUnion(vtmp3) = { Volume{vtmp2}; Delete;}{ Volume{vconn3}; Delete;};

vlowerswash = newv;
BooleanUnion(vlowerswash) = { Volume{vtmp3}; Delete;}{ Volume{vconn4}; Delete;};

Return
//
Function CreateBasePlate

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
roffset = pushrod_roffset;
baseplate_vnum = NewVolume;
Call AddPushRodHole;
Printf("Baseplate volume is (%g)", NewVolume);

// Add push rod hole at 180 degrees
aoffset = Pi;
roffset = pushrod_roffset;
baseplate_vnum = NewVolume;
Call AddPushRodHole;
Printf("Baseplate volume is (%g)", NewVolume);

// Add push rod hole at 270 degrees
aoffset = 3.0*Pi/2.0;
roffset = pushrod_roffset;
baseplate_vnum = NewVolume;
Call AddPushRodHole;
Printf("Baseplate volume is (%g)", NewVolume);

// Create a block volume to be cut from the base plate
aoffset = 0.0;
baseplate_vnum = NewVolume;
Call CutBlockFromBasePlate;
Printf("Cutblock Baseplate volume is (%g)", NewVolume);
Return
//
Function CreatePushRod90
//-------------------------------------------------------------------//
// Create a body cylinder
//-------------------------------------------------------------------//

// Pushrod at 90 degrees

aoffset   = Pi/2.0;
roffset   = pushrod_roffset;

xbcy      = x_base + roffset*Cos(aoffset);
ybcy      = y_base + roffset*Sin(aoffset);
zbcy      = z_base;

hrod      = pushrod_height;
rrod      = pushrod_base_radius;

vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rrod, 2*Pi};
Printf("Created body pushrod cylinder = %g", vbody);

//-------------------------------------------------------------------//
// Create a head cylinder
//-------------------------------------------------------------------//

hcy   = 2*pushrod_inner_radius;
rcy   = pushrod_outer_radius;

xcy   = x_base + roffset*Cos(aoffset) - hcy/2.0;
ycy   = y_base + roffset*Sin(aoffset); 
zcy   = z_lower_swash + lower_swash_height/2.0 ;

vhead = newv;
Cylinder(vhead) = {xcy, ycy, zcy, hcy, 0, 0, rcy, 2*Pi};
Printf("Created head pushrod cylinder = %g", vhead);

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

// Punch a spherical hole on the head
xcy   = x_base + roffset*Cos(aoffset);
ycy   = y_base + roffset*Sin(aoffset); 
zcy   = z_lower_swash + lower_swash_height/2.0 ;

vspheretmp = newv;
Sphere(vspheretmp) = {xcy, ycy, zcy, pushrod_sphere_radius, -Pi/2, Pi/2, 2*Pi};
Printf("Punched spherical hole in pushrod = %g", vspheretmp);
v = newv;
BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vspheretmp}; Delete; };

// Punch a cylindrical hole on the head
//hcy   = 2*pushrod_inner_radius;
//rcy   = pushrod_inner_radius;
//vcyltmp = newv;
//Cylinder(vcyltmp) = {xcy, ycy, zcy, hcy, 0, 0, rcy, 2*Pi};
//Printf("Punched cylindrical hole in pushrod = %g", vcyltmp);
//v = newv;
//BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vcyltmp}; Delete; };
Return
//
Function CreatePushRod180
// Pushrod at 180 degrees
//-------------------------------------------------------------------//
// Create a body cylinder
//-------------------------------------------------------------------//
aoffset   = Pi;
roffset   = pushrod_roffset;

xbcy      = x_base + roffset*Cos(aoffset);
ybcy      = y_base + roffset*Sin(aoffset);
zbcy      = z_base;

hrod      = pushrod_height;
rrod      = pushrod_base_radius;

vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rrod, 2*Pi};
Printf("Created body pushrod cylinder = %g", vbody);

//-------------------------------------------------------------------//
// Create a head cylinder
//-------------------------------------------------------------------//

hcy   = 2*pushrod_inner_radius;
rcy   = pushrod_outer_radius;

xcy   = x_base + roffset*Cos(aoffset);
ycy   = y_base + roffset*Sin(aoffset)- hcy/2.0; 
zcy   = z_lower_swash + lower_swash_height/2.0 ;

vhead = newv;
Cylinder(vhead) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created head pushrod cylinder = %g", vhead);

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

// Punch a spherical hole on the head
xcy   = x_base + roffset*Cos(aoffset);
ycy   = y_base + roffset*Sin(aoffset); 
zcy   = z_lower_swash + lower_swash_height/2.0 ;

vspheretmp = newv;
Sphere(vspheretmp) = {xcy, ycy, zcy, pushrod_sphere_radius, -Pi/2, Pi/2, 2*Pi};
Printf("Punched spherical hole in pushrod = %g", vspheretmp);
v = newv;
BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vspheretmp}; Delete; };

// Punch a cylindrical hole on the head
//hcy   = 2*pushrod_inner_radius;
//rcy   = pushrod_inner_radius;
//vcyltmp = newv;
//Cylinder(vcyltmp) = {xcy, ycy, zcy, hcy, 0, 0, rcy, 2*Pi};
//Printf("Punched cylindrical hole in pushrod = %g", vcyltmp);
//v = newv;
//BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vcyltmp}; Delete; };
Return
//
Function CreatePushRod270
// Pushrod at 270 degrees
//-------------------------------------------------------------------//
// Create a body cylinder
//-------------------------------------------------------------------//
aoffset = 3.0*Pi/2.0;
roffset   = pushrod_roffset;

xbcy      = x_base + roffset*Cos(aoffset);
ybcy      = y_base + roffset*Sin(aoffset);
zbcy      = z_base;

hrod      = pushrod_height;
rrod      = pushrod_base_radius;

vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rrod, 2*Pi};
Printf("Created body pushrod cylinder = %g", vbody);

//-------------------------------------------------------------------//
// Create a head cylinder
//-------------------------------------------------------------------//

hcy   = 2*pushrod_inner_radius;
rcy   = pushrod_outer_radius;

xcy   = x_base + roffset*Cos(aoffset) - hcy/2.0;
ycy   = y_base + roffset*Sin(aoffset); 
zcy   = z_lower_swash + lower_swash_height/2.0 ;

vhead = newv;
Cylinder(vhead) = {xcy, ycy, zcy, hcy, 0, 0, rcy, 2*Pi};
Printf("Created head pushrod cylinder = %g", vhead);

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

// Punch a spherical hole on the head
xcy   = x_base + roffset*Cos(aoffset);
ycy   = y_base + roffset*Sin(aoffset); 
zcy   = z_lower_swash + lower_swash_height/2.0 ;

vspheretmp = newv;
Sphere(vspheretmp) = {xcy, ycy, zcy, pushrod_sphere_radius, -Pi/2, Pi/2, 2*Pi};
Printf("Punched spherical hole in pushrod = %g", vspheretmp);
v = newv;
BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vspheretmp}; Delete; };

// Punch a cylindrical hole on the head
//hcy   = 2*pushrod_inner_radius;
//rcy   = pushrod_inner_radius;
//vcyltmp = newv;
//Cylinder(vcyltmp) = {xcy, ycy, zcy, hcy, 0, 0, rcy, 2*Pi};
//Printf("Punched cylindrical hole in pushrod = %g", vcyltmp);
//v = newv;
//BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vcyltmp}; Delete; };
Return
//