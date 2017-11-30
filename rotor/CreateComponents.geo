Function CreateDoubleUpperSwashPlate
aoffset = 0;

//-------------------------------------------------------------------//
// Add a block to the swash plate
//-------------------------------------------------------------------//

dxtmp = uswash_outer_radius;
dytmp = swash_connplate_length;
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

// create a new sphere cap to add to the link
pspherecap = newp;
Point(pspherecap) = {xlink, ylink + link_length/2.0, zlink}; // a joint location
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
Printf("usp_sphere_coordinates: %f %f %f", 
                                x_upper_swash, 
                                y_upper_swash, 
                                z_upper_swash+upper_swash_height/2.0);
Printf("lsp_usp_coordinates: %f %f %f", 
                                x_upper_swash, 
                                y_upper_swash, 
                                z_upper_swash);

// Remove the piece separately
vpiece = newv;
BooleanDifference(vpiece) = { Volume{v}; Delete;}{ Volume{vcyl};};

// Now add the piece to the cylinder
vnew = newv;
BooleanUnion(vnew) = { Volume{vcyl}; Delete;}{ Volume{vpiece}; Delete;};

//out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi} {
//Duplicata { Volume{vnew}; }
//};
//vconn2 = out[0];

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, upper_swash_angle} {
Volume{vnew};
};
vconn3 = out[0];

// Figure out the rotated point
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, upper_swash_angle} {
Point{pspherecap};
};
prot = out[0]; // Rotated joint location
Printf("usp_lpl ball coordinates %f %f %f at %f rad", Point{prot}, upper_swash_angle);

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi} {
Duplicata { Volume{vconn3}; }
};
vconn4 = out[0];

// Figure out the rotated point
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi} {
Duplicata{ Point{prot}; }
};
prot2 = out[0]; // Rotated joint location
Printf("usp_lpl ball coordinates %f %f %f at %f rad", Point{prot2}, Pi + upper_swash_angle);

// Unite all volumes into one
vplate = newv;
BooleanUnion(vplate) = { Volume{vnew}; Delete;}{ Volume{vconn4}; Delete;};

// create a new sphere to cut
X_sphere =  x_sphere;
Y_sphere =  y_sphere;
Z_sphere =  z_sphere;
vsp = newv;
Sphere(vsp) = {X_sphere, Y_sphere, Z_sphere, sphere_radius, -Pi/4, Pi/4, 2*Pi};

vupperswash = newv;
BooleanDifference(vupperswash) = { Volume{vplate}; Delete; }{ Volume{vsp}; Delete; };
Printf("Created upper swash volume (%g)", vupperswash);
Return
//
Function CreateLowerSwashPlate
aoffset = 0;

//-------------------------------------------------------------------//
// Add a block to the swash plate
//-------------------------------------------------------------------//

dxtmp = base_radius;
dytmp = swash_connplate_length;
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

// vnew = Fillet{vnew}{23, 24, 28, 14}{fillet_radius};

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi/2} {
Duplicata { Volume{vnew}; }
};
vconn2 = out[0];

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi/2} {
Duplicata { Volume{vconn2}; }
};
vconn3 = out[0];

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi/2} {
Duplicata { Volume{vconn3}; }
};
vconn4 = out[0];

// Unite all volumes into one
v1 = newv;
BooleanUnion(v1) = { Volume{vconn3}; Delete;}{ Volume{vconn4}; Delete;};

v2 = newv;
BooleanUnion(v2) = { Volume{vnew}; Delete;}{ Volume{vconn2}; Delete;};

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
out[] = Translate {xtrans, ytrans, ztrans} { Volume{vlowerswash}; };
vlowerswash = out[0];
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

// Constraint point between baseplate and hub shaft
P_BSP_HUB = newp;
Point(P_BSP_HUB) = {xcy, ycy, zcy};
Printf("P_BSP_HUB %.16f %.16f %.16f ", Point{P_BSP_HUB});

// Add push rod hole at 90 degrees
aoffset = Pi/2.0;
roffset = pushrod_roffset;
baseplate_vnum = NewVolume;
Call AddPushRodHole;

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
out[] = Translate {xtrans, ytrans, ztrans} { Volume{vbaseplate}; };
vbaseplate = out[0];
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

P_PROD90_BSP = newp;
Point(P_PROD90_BSP) = {xbcy, ybcy, zbcy};
Printf("P_PROD90_BSP %.16f %.16f %.16f ", Point{P_PROD90_BSP});

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

P_PROD90_LSP = newp;
Point(P_PROD90_LSP) = {xcy, ycy, zcy};
Printf("P_PROD90_LSP %.16f %.16f %.16f ", Point{P_PROD90_LSP});

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
out[] = Translate {xtrans, ytrans, ztrans} { Volume{v}; };
v = out[0];
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

P_PROD180_BSP = newp;
Point(P_PROD180_BSP) = {xbcy, ybcy, zbcy};
Printf("P_PROD180_BSP %.16f %.16f %.16f ", Point{P_PROD180_BSP});

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

P_PROD180_LSP = newp;
Point(P_PROD180_LSP) = {xcy, ycy, zcy};
Printf("P_PROD180_LSP %.16f %.16f %.16f ", Point{P_PROD180_LSP});

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
out[] = Translate {xtrans, ytrans, ztrans} { Volume{v}; };
v = out[0];
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

P_PROD270_BSP = newp;
Point(P_PROD270_BSP) = {xbcy, ybcy, zbcy};
Printf("P_PROD270_BSP %.16f %.16f %.16f ", Point{P_PROD270_BSP});

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

P_PROD270_LSP = newp;
Point(P_PROD270_LSP) = {xcy, ycy, zcy};
Printf("P_PROD270_LSP %.16f %.16f %.16f ", Point{P_PROD270_LSP});

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
out[] = Translate {xtrans, ytrans, ztrans} { Volume{v}; };
v = out[0];
Return
//
Function CreateBladeX
// Airfoil
cl       = 0.01;  // characteristic length of the mesh //0.01
chord    = 0.121; // chord of the airfoil
r_cutout = 0.44;  // cutout radius of the root
R        = 2.0;   // Tip radius
r_tw     = 1.5;                     // radius of zero twist (m)
b_len    = R - r_cutout;            // blade length (m)
theta_tw = -8.0;                    // linear twist (deg)
dtheta   = theta_tw/(R-r_cutout)*Pi/180; //linear twist rate (rad/m)

// The following variables must be set on entry:
// NACA4_th       : thickness in percent of chord
// NACA4_ch       : aerofoil chord
// NACA4_le_x,y,z : leading edge coordinates
// NACA4_len_te   : length scale (trailing edge)
// NACA4_len_mc   : length scale (mid chord)
// NACA4_len_le   : length scale (leading edge)
// NACA4_nspl     : number of splines on section
// NACA4_pps      : number of points per spline

// NACA4_npts = NACA4_nspl*NACA4_pps ;

NACA4_nspl   = 4 ;
NACA4_pps    = 5 ;

NACA4_len_le = cl ; // unused
NACA4_len_mp = cl ; // unused
NACA4_len_te = cl ; // unused

NACA4_th     = 12 ;
NACA4_ch     = 0.121 ;
NACA4_le_x   = -0.121/2.0; // Span/2*Sin(Sweep) ;
NACA4_le_y   = 0.0 ; // actually z
NACA4_le_z   = R; // r_cutout ; // actually y

// Create the airfoil 
Call NACA4 ;

ll = newll ;
Line Loop(ll) = NACA4_Splines[] ;

s = news ;
Plane Surface(s) = {ll};

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, -Pi/2.0} {
Surface{s};
};
srotated = out[0];

// Extrude the surface to create a volume
out[] = Extrude {r_cutout-R, 0, 0} { Surface{srotated}; Layers{(R-r_cutout)/cl }; };
vblade = out[1];
sbc = out[0];

Printf("volume of the blade %g", vblade);
Printf("Boundary surface is %g", sbc);

//surfaces contains in the following order:
//[0] - front surface (opposed to source surface)
//[1] - extruded volume

//[2] - bottom surface (belonging to 1st line in "Line Loop (6)")
//[3] - right surface (belonging to 2nd line in "Line Loop (6)")
//[4] - top surface (belonging to 3rd line in "Line Loop (6)")
//[5] - left surface (belonging to 4th line in "Line Loop (6)") 
// Looking from TOP at XY plane according to gmsh convention
// Physical Surface("bottom_hub_surface", newp) = sbc;
//Physical Surface("lateral_surface", 4) = {out[2], out[3], out[4], out[5]};
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, 2.0*Pi} {
Volume{vblade};
};
vblade = out[0];
// Translate the blade to offset
out[] = Translate {xtrans, ytrans, ztrans} { Volume{vblade}; };
vblade = out[0];
Return
//
Function CreateBladeCapX
//--------------------------------------------------------------------//
// Create a blade connector body
//--------------------------------------------------------------------//
xbconn = x_blade + cutout_radius;
ybconn = y_blade;
zbconn = z_blade;

dx = -blade_conn_length*Cos(0);
dy = -blade_conn_length*Sin(0);
dz = 0;

vbladecap = newv;
Cylinder(vbladecap) = {xbconn, ybconn, zbconn, dx, dy, dz, blade_conn_radius, 2*Pi};
// Translate the blade to offset
out[] = Translate {xtrans, ytrans, ztrans} { Volume{vbladecap}; };
vbladecap = out[0];
Return
//
Function CreateBladeCapNegativeX
Call CreateBladeCapX;
out[] = Rotate {{0, 0, 1}, {xtrans, ytrans, ztrans}, Pi} {
Volume{vbladecap};
};
Return
//
Function CreateBladeCapY
Call CreateBladeCapX;
out[] = Rotate {{0, 0, 1}, {xtrans, ytrans, ztrans}, Pi/2.0} {
Volume{vbladecap};
};
Return
//
Function CreateBladeCapNegativeY
Call CreateBladeCapX;
out[] = Rotate {{0, 0, 1}, {xtrans, ytrans, ztrans}, -Pi/2.0} {
Volume{vbladecap};
};
Return
//
Function CreateFourBladeHub
// Shaft cylinder
vshaft = newv;
dz = shaft_height - hub_height;
Cylinder(vshaft) = {x_hub, y_hub, z_hub, 
                 0, 0, dz, shaft_radius, 2*Pi};
Printf("Created shaft volume (%g)", vshaft);

// Constraint point between hub shaft and origin
P_HUB_ORIG = newp;
Point(P_HUB_ORIG) = {x_hub, y_hub, z_hub};
Printf("P_HUB_ORIG %.16f %.16f %.16f ", Point{P_HUB_ORIG});

// Hub cylinder
vhub = newv;
Cylinder(vhub) = {x_hub, y_hub, z_hub + dz, 
               0, 0, hub_height, hub_radius, 2*Pi};
Printf("Created hub volume (%g)", vhub);

// 
vtot = newv;
BooleanUnion(vtot) = { Volume{vshaft}; Delete; }{ Volume{vhub}; Delete; };
Printf("Combined shaft and hub volume (%g)", vtot);
////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------//
// Create a hub connector body on right along X
//--------------------------------------------------------------------//

dx = hub_conn_length + hub_radius;

xhconn = x_hub - dx;
yhconn = y_hub;
zhconn = z_hub + shaft_height - hub_height/2.0;

vhubconntmp = newv;
Cylinder(vhubconntmp) = {xhconn, yhconn, zhconn, 2.0*dx, 0, 0, hub_conn_radius, 2*Pi};

vfinal = newv;
BooleanUnion(vfinal) = { Volume{vtot}; Delete; }{ Volume{vhubconntmp}; Delete; };

P_HUB_UPL30 = newp;
Point(P_HUB_UPL30) = {hub_radius + hub_conn_length, yhconn, zhconn};
Printf("P_HUB_UPL30 %.16f %.16f %.16f ", Point{P_HUB_UPL30});

P_HUB_UPL210 = newp;
Point(P_HUB_UPL210) = {-(hub_radius + hub_conn_length), yhconn, zhconn};
Printf("P_HUB_UPL210 %.16f %.16f %.16f ", Point{P_HUB_UPL210});
//
dy = hub_conn_length + hub_radius;

xhconn = x_hub;
yhconn = y_hub - dy;
zhconn = z_hub + shaft_height - hub_height/2.0;

vhubconntmp = newv;
Cylinder(vhubconntmp) = {xhconn, yhconn, zhconn, 0, 2.0*dy, 0, hub_conn_radius, 2*Pi};

vfinal1 = newv;
BooleanUnion(vfinal1) = { Volume{vfinal}; Delete; }{ Volume{vhubconntmp}; Delete; };
vhub = vfinal1;

P_HUB_UPL120 = newp;
Point(P_HUB_UPL120) = {xhconn, hub_radius + hub_conn_length, zhconn};
Printf("P_HUB_UPL120 %.16f %.16f %.16f ", Point{P_HUB_UPL120});

P_HUB_UPL300 = newp;
Point(P_HUB_UPL300) = {xhconn, -(hub_radius + hub_conn_length), zhconn};
Printf("P_HUB_UPL300 %.16f %.16f %.16f ", Point{P_HUB_UPL300});
//
out[] = Translate {xtrans, ytrans, ztrans} { Volume{vhub}; };
vhub = out[0];
Return
//
Function CreateDoubleBladeHub
// Shaft cylinder
vshaft = newv;
dz = shaft_height - hub_height;
Cylinder(vshaft) = {x_hub, y_hub, z_hub, 
                 0, 0, dz, shaft_radius, 2*Pi};
Printf("Created shaft volume (%g)", vshaft);

// Constraint point between hub shaft and origin
P_HUB_ORIG = newp;
Point(P_HUB_ORIG) = {x_hub, y_hub, z_hub};
Printf("P_HUB_ORIG %.16f %.16f %.16f ", Point{P_HUB_ORIG});

// Hub cylinder
vhub = newv;
Cylinder(vhub) = {x_hub, y_hub, z_hub + dz, 
               0, 0, hub_height, hub_radius, 2*Pi};
Printf("Created hub volume (%g)", vhub);

// 
vtot = newv;
BooleanUnion(vtot) = { Volume{vshaft}; Delete; }{ Volume{vhub}; Delete; };
Printf("Combined shaft and hub volume (%g)", vtot);
////////////////////////////////////////////////////////////////////////

//--------------------------------------------------------------------//
// Create a hub connector body on right
//--------------------------------------------------------------------//

dx = hub_conn_length + hub_radius;

xhconn = x_hub - dx;
yhconn = y_hub;
zhconn = z_hub + shaft_height - hub_height/2.0;

vhubconntmp = newv;
Cylinder(vhubconntmp) = {xhconn, yhconn, zhconn, 2.0*dx, 0, 0, hub_conn_radius, 2*Pi};

vfinal = newv;
BooleanUnion(vfinal) = { Volume{vtot}; Delete; }{ Volume{vhubconntmp}; Delete; };
vhub = vfinal1;

P_HUB_UPL30 = newp;
Point(P_HUB_UPL30) = {hub_radius + hub_conn_length, yhconn, zhconn};
Printf("P_HUB_UPL30 %.16f %.16f %.16f ", Point{P_HUB_UPL30});

P_HUB_UPL210 = newp;
Point(P_HUB_UPL210) = {-(hub_radius + hub_conn_length), yhconn, zhconn};
Printf("P_HUB_UPL210 %.16f %.16f %.16f ", Point{P_HUB_UPL210});
//
Return
//
Function CreateBladeNegativeX
Call CreateBladeX;
out[] = Rotate {{0, 0, 1}, {xtrans, ytrans, ztrans}, Pi} {
Volume{vblade};
};
Return
//
//
Function CreateBladeNegativeY
Call CreateBladeX;
out[] = Rotate {{0, 0, 1}, {xtrans, ytrans, ztrans}, -Pi/2.0} {
Volume{vblade};
};
Return
//
Function CreateBladeY
Call CreateBladeX;
out[] = Rotate {{0, 0, 1}, {xtrans, ytrans, ztrans}, Pi/2.0} {
Volume{vblade};
};
Return
//
Function CreateLowerPushHorn
//-------------------------------------------------------------------//
// Create a body cylinder
//-------------------------------------------------------------------//

xbcy = xloc;
ybcy = yloc;
zbcy = zloc;

Printf("LPH tail center coordinates %f %f %f", xloc, yloc, zloc);

hrod = horn_length;
rrod = 0.99*horn_base_radius;

vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rrod, 2*Pi};
Printf("Created body lower pushrod cylinder = %g", vbody);

//-------------------------------------------------------------------//
// Create a tail cylinder
//-------------------------------------------------------------------//

hcy = 2*horn_base_radius;
rcy = horn_outer_radius;

xcy = xloc;
ycy = yloc - horn_base_radius;
zcy = zloc;

vtail = newv;
Cylinder(vtail) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created tail pushrod cylinder = %g", vtail);

// Unite the body and tail to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vtail}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

// Punch a cylindrical hole on the tail
hcy   = 2*horn_base_radius;
rcy   = horn_inner_radius;
vcyltmp = newv;
Cylinder(vcyltmp) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Punched cylindrical hole in pushrod = %g", vcyltmp);
v = newv;
BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vcyltmp}; Delete; };

//-------------------------------------------------------------------//
// Create a head cylinder
//-------------------------------------------------------------------//

hcy   = 2*horn_base_radius;
rcy   = horn_outer_radius;

xcy   = xloc;
ycy   = yloc - horn_base_radius;
zcy   = zloc + horn_length;

vhead = newv;
Cylinder(vhead) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created head pushrod cylinder = %g", vhead);

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{v}; Delete; };
NewVolume = vtot;

xcy   = xloc;
ycy   = yloc - horn_base_radius;
zcy   = zloc + horn_length;

vhead1 = newv;
Cylinder(vhead1) = {xcy, ycy, zcy, 0, hcy/4.0, 0, rcy, 2*Pi};
Printf("Created head pushrod cylinder = %g", vhead1);

vtmp = newv;
BooleanDifference(vtmp) = { Volume{vtot}; Delete; }{ Volume{vhead1}; Delete; };

xcy   = xloc;
ycy   = yloc + horn_base_radius;
zcy   = zloc + horn_length;

vhead2 = newv;
Cylinder(vhead2) = {xcy, ycy, zcy, 0, -hcy/4.0, 0, rcy, 2*Pi};
Printf("Created head pushrod cylinder = %g", vhead2);

vtot = newv;
BooleanDifference(vtot) = { Volume{vtmp}; Delete; }{ Volume{vhead2}; Delete; };

// Punch a cylindrical hole on the head

xcy   = xloc;
ycy   = yloc + horn_base_radius;
zcy   = zloc + horn_length;

hcy   = 2*horn_base_radius;
rcy   = horn_bolt_radius;

vcyltmp = newv;
Cylinder(vcyltmp) = {xcy, ycy, zcy, 0, -hcy, 0, rcy, 2*Pi};
Printf("Punched cylindrical hole in pushrod = %g", vcyltmp);
vlowerpushhorn = newv;
BooleanUnion(vlowerpushhorn) = { Volume{vtot}; Delete; }{ Volume{vcyltmp}; Delete; };
//

out[] = Rotate {{0, 1, 0}, {xloc, yloc, zloc}, pushrod_angle} {
Volume{vlowerpushhorn};
};
vfinal = out[0];
vlph = vfinal;

// Lower hinge point
p = newp;
Point(p) = {xloc, yloc, zloc + horn_length};
out[] = Rotate {{0, 1, 0}, {xloc, yloc, zloc}, pushrod_angle} {
Point{p};
};
phinge = out[0];
NewPoint = phinge;
Printf("LPH head center coordinates %f %f %f", Point{phinge});
Delete{ Point{phinge};}

out[] = Translate {xtrans, ytrans, ztrans} { Volume{vlph}; };
vlph = out[0];

Return
//
Function CreateUpperPushHorn
// Set xloc, yloc, zloc
//-------------------------------------------------------------------//
// Create a body cylinder
//-------------------------------------------------------------------//

xbcy = xloc;
ybcy = yloc;
zbcy = zloc;

Printf("UPH head center coordinates %f %f %f", xloc, yloc, zloc);

hrod = horn_length;
rrod = 0.99*horn_base_radius;

vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, -hrod, rrod, 2*Pi};
Printf("Created body pushrod cylinder = %g", vbody);

//-------------------------------------------------------------------//
// Create a HEAD cylinder with spherical cavity
//-------------------------------------------------------------------//

hcy   = 2*horn_base_radius;
rcy   = horn_outer_radius;

xcy   = xloc;
ycy   = yloc - horn_base_radius;
zcy   = zloc ;

vhead = newv;
Cylinder(vhead) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created head pushrod cylinder = %g", vhead);

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

// Punch a spherical hole on the head
xcy   = xloc;
ycy   = yloc;
zcy   = zloc;

vspheretmp = newv;
Sphere(vspheretmp) = {xcy, ycy, zcy, pushrod_sphere_radius, -Pi/2, Pi/2, 2*Pi};
Printf("Punched spherical hole in pushrod = %g", vspheretmp);
v = newv;
BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vspheretmp}; Delete; };

//-------------------------------------------------------------------//
// Create a TAIL cylinder with REVOLUTE cavity
//-------------------------------------------------------------------//
// 1. Add a cylinder of full height and radius

hcy   = 2*horn_base_radius;
rcy   = horn_outer_radius;

xcy   = xloc;
ycy   = yloc - horn_base_radius;
zcy   = zloc - horn_length;

vtail1 = newv;
Cylinder(vtail1) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created tail pushrod cylinder = %g", vtail1);

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{v}; Delete; }{ Volume{vtail1}; Delete; };
NewVolume = vtot;

// Cut a cylinder of same radius but quarter height moved inside

xcy   = xloc;
ycy   = yloc - horn_base_radius/2.0;
zcy   = zloc - horn_length;

vtail2 = newv;
Cylinder(vtail2) = {xcy, ycy, zcy, 0, hcy/2.0, 0, rcy, 2*Pi};
Printf("Created tail pushrod cylinder = %g", vtail2);

// Unite the body and head to make the pushrod
vtot2 = newv;
BooleanDifference(vtot2) = { Volume{vtot}; Delete; }{ Volume{vtail2}; Delete; };
NewVolume = vtot2;

// Cut a cylinder of full height but bolt radius
xcy   = xloc;
ycy   = yloc - horn_base_radius;
zcy   = zloc - horn_length;
rcy   = horn_bolt_radius;

vhole = newv;
Cylinder(vhole) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created tail pushrod cylinder = %g", vhole);

// Unite the body and head to make the pushrod
vfinal = newv;
BooleanDifference(vfinal) = { Volume{vtot2}; Delete; }{ Volume{vhole}; Delete; };

out[] = Rotate {{0, 1, 0}, {xloc, yloc, zloc}, -pushrod_angle} {
Volume{vfinal};
};
vfinal = out[0];
vuph = vfinal;

// Upper hinge point
p = newp;
Point(p) = {xloc, yloc, zloc - horn_length};
out[] = Rotate {{0, 1, 0}, {xloc, yloc, zloc}, -pushrod_angle} {
Point{p};
};
phinge = out[0];
NewPoint = phinge;
Printf("UPH tail center coordinates %f %f %f", Point{phinge});
Delete{ Point{phinge};}
//
out[] = Translate {xtrans, ytrans, ztrans} { Volume{vuph}; };
vuph = out[0];
Return
//


Function CreateLowerPitchLink
// angle is the input

// Spherical cap point on the upper swash plate

x = uswash_outer_radius*Cos(aoffset) - link_length/2.0;
y = uswash_outer_radius*Sin(aoffset);
z = z_upper_swash + upper_swash_height/2.0;

// Infer this point geometrically
xloc = x*Cos(theta) - y*Sin(theta);
yloc = x*Sin(theta) + y*Cos(theta);
zloc = z;

// Create a spherical body of height upto half of the hub
xbcy = xloc;
ybcy = yloc;
zbcy = zloc;

hrod = pitchlink_length;
rrod = 0.99*horn_base_radius;
Printf("Pitchlink length = %f", hrod);

plplupl = newp;
Point(plplupl) = {xbcy, ybcy, zbcy + hrod}; // a joint point

vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rrod, 2*Pi};
Printf("Created body pitchlink cylinder = %g", vbody);

//-------------------------------------------------------------------//
// Create a HEAD cylinder with spherical cavity
//-------------------------------------------------------------------//

hcy   = 2*horn_base_radius;
rcy   = horn_outer_radius;

xcy   = xloc;
ycy   = yloc - horn_base_radius;
zcy   = zloc;

vhead = newv;
Cylinder(vhead) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created head pitchlink cylinder = %g", vhead);

// Unite the body and head to make the pitchlink
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

// Punch a spherical hole on the head
xcy   = xloc;
ycy   = yloc;
zcy   = zloc;

vspheretmp = newv;
Sphere(vspheretmp) = {xcy, ycy, zcy, pitchlink_sphere_radius, -Pi/2, Pi/2, 2*Pi};
Printf("Punched spherical hole in pitchlink = %g", vspheretmp);
v = newv;
BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vspheretmp}; Delete; };

// Rotate the male pitch link to align with the base
out[] = Rotate {{0, 0, 1}, {xloc, yloc, zloc}, upper_swash_angle} {
Volume{v};
};
vpitch = out[0];

// Attach a male part with cylindrical head and punched nut at the other end of the rod
hcy   = 2*horn_base_radius;
rcy   = horn_outer_radius;

ycy   = yloc;
xcy   = xloc - horn_base_radius;
zcy   = zloc + pitchlink_length;

vmale = newv;
Cylinder(vmale) = {xcy, ycy, zcy, hcy, 0, 0, rcy, 2*Pi};

// Unite the bolt with body
vtmp = newv;
BooleanDifference(vtmp) = { Volume{vpitch}; Delete;}{ Volume{vmale};};

vnew = newv;
BooleanUnion(vnew) = { Volume{vtmp}; Delete;}{ Volume{vmale}; Delete;};

// Add a bolt
hcy   = 2.0*2.0*horn_base_radius;
rcy   = horn_bolt_radius;
ycy   = yloc;
xcy   = xloc - 2.0*horn_base_radius;
zcy   = zloc + pitchlink_length;

vbolt = newv;
Cylinder(vbolt) = {xcy, ycy, zcy, hcy, 0, 0, rcy, 2*Pi};

// Unite the bolt with body
vtot = newv;
BooleanDifference(vtot) = { Volume{vnew}; Delete;}{ Volume{vbolt}; Delete;};
vlowerpitch0 = vtot;
Return
//
Function CreateUpperPitchLink
//
aoffset = 0;
x = uswash_outer_radius*Cos(aoffset) - link_length/2.0;
y = uswash_outer_radius*Sin(aoffset) ;
z = z_blade;

// Rotate the joint point
xloc = x*Cos(theta) - y*Sin(theta);
yloc = x*Sin(theta) + y*Cos(theta) + horn_outer_radius;
zloc = z;
Printf("Upper Pitchlink coordinates %f %f %f", xloc, yloc, zloc);

// Create a cylinder that extends along y-direction
dy = yloc - y_blade;

// Extend a connector
v = newv;
rad = 3.0*horn_base_radius;
Cylinder(v) = {xloc, yloc, zloc, 0, -dy, 0, rad, 2*Pi};

// Cut out a slot for the hinge
dx = 2*2*horn_base_radius;
dy = 2*horn_base_radius;
dz = 3.0*horn_base_radius;
vblock = newv;
Block(vblock) = {xloc-2*horn_base_radius, 
              yloc, 
              zloc-3.0*horn_base_radius, 
              dx, -2.5*dy, 2.0*dz};

v1 = newv;
BooleanDifference(v1) = { Volume{v}; Delete; }{ Volume{vblock}; Delete; };

// Add a bolt
hcy   = 2*2*horn_base_radius;
rcy   = horn_bolt_radius;
ycy   = yloc - 2*horn_base_radius;
xcy   = xloc - 2.0*horn_base_radius;
zcy   = zloc;
//
vbolt = newv;
Cylinder(vbolt) = {xcy, ycy, zcy, hcy, 0, 0, rcy, 2*Pi};
//
// Unite the bolt with body
vtot = newv;
BooleanUnion(vtot) = { Volume{v1}; Delete;}{ Volume{vbolt}; Delete;};
//
// Add a connector cylinder along x direction from the hub connector
// to the blade connector
dx = hub_blade_conn_length;
xloc = hub_radius + hub_conn_length;
yloc = y_blade;
zloc = z_blade;
vhbconn = newv;
Cylinder(vhbconn) = {xloc, yloc, zloc, dx, 0, 0, rad, 2*Pi};
//
v2 = newv;
BooleanDifference(v2) = { Volume{vtot}; Delete; }{ Volume{vhbconn};};
//
v3 = newv;
BooleanUnion(v3) = { Volume{v2}; Delete; }{ Volume{vhbconn}; Delete;};
vupperpitch0 = v3;
Return
//
Function CreateSphere
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
vsphere = vtot;
out[] = Translate {xtrans, ytrans, ztrans} { Volume{vsphere}; };
vsphere = out[0];
Return
//
Function CreateFourUpperSwashPlate
aoffset = 0;
//-------------------------------------------------------------------//
// Add a block to the swash plate
//-------------------------------------------------------------------//

dxtmp = uswash_outer_radius;
dytmp = swash_connplate_length;
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

//-------------------------------------------------------------------//
// create a new sphere cap to add to the link
//-------------------------------------------------------------------//

pspherecap = newp;
Point(pspherecap) = {xlink, ylink + link_length/2.0, zlink}; // a joint location
vspheretmp = newv;
Sphere(vspheretmp) = {xlink, ylink + link_length/2.0 , zlink, pushrod_sphere_radius, -Pi/2, Pi/2, 2*Pi};
vlink  = newv;
BooleanUnion(vlink) = { Volume{vlinktmp}; Delete;}{ Volume{vspheretmp}; Delete;};

// Add the spherical headed connector to the total volume of the plate
v = newv;
BooleanUnion(v) = { Volume{vtot}; Delete;}{ Volume{vlink}; Delete;};

//-------------------------------------------------------------------//
//                   MAIN CYLINDRICAL PLATE
//-------------------------------------------------------------------//

vcyl = newv;
Cylinder(vcyl) = {x_upper_swash, y_upper_swash, z_upper_swash, 0, 0, upper_swash_height, upper_swash_radius, 2*Pi};
Printf("usp_sphere_coordinates: %f %f %f", 
                                x_upper_swash, 
                                y_upper_swash, 
                                z_upper_swash+upper_swash_height/2.0);
Printf("lsp_usp_coordinates: %f %f %f", 
                                x_upper_swash, 
                                y_upper_swash, 
                                z_upper_swash);

// Remove the piece separately
vpiece = newv;
BooleanDifference(vpiece) = { Volume{v}; Delete;}{ Volume{vcyl};};

// Now add the piece to the cylinder
vnew = newv;
BooleanUnion(vnew) = { Volume{vcyl}; Delete;}{ Volume{vpiece}; Delete;};

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, upper_swash_angle} {
Volume{vnew};
};
vconn3 = out[0];

// Figure out the rotated point
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, upper_swash_angle} {
Point{pspherecap};
};
prot = out[0]; // Rotated joint location
Printf("usp_lpl ball coordinates %f %f %f at %f rad", Point{prot}, upper_swash_angle*180.0/Pi);

// 180 degrees
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi} {
Duplicata { Volume{vconn3}; }
};
vconn4 = out[0];

// Figure out the rotated point
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi} {
Duplicata{ Point{prot}; }
};
prot2 = out[0]; // Rotated joint location
Printf("usp_lpl ball coordinates %f %f %f at %f rad", Point{prot2}, (Pi + upper_swash_angle)*180.0/Pi);

// 90 degrees
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi/2.0} {
Duplicata { Volume{vconn3}; }
};
vconn5 = out[0];

// Figure out the rotated point
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi/2.0} {
Duplicata{ Point{prot}; }
};
prot3 = out[0]; // Rotated joint location
Printf("usp_lpl ball coordinates %f %f %f at %f rad", Point{prot3}, (Pi/2.0 + upper_swash_angle)*180.0/Pi);

// 270 degrees
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, -Pi/2.0} {
Duplicata { Volume{vconn3}; }
};
vconn6 = out[0];

// Figure out the rotated point
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, -Pi/2.0} {
Duplicata{ Point{prot}; }
};
prot3 = out[0]; // Rotated joint location
Printf("usp_lpl ball coordinates %f %f %f at %f rad", Point{prot3}, (3.0*Pi/2.0 + upper_swash_angle)*180.0/Pi);


// Unite all volumes into one
vplate = newv;
BooleanUnion(vplate) = { Volume{vnew}; Delete;}{ Volume{vconn4}; Delete;};

vplate1 = newv;
BooleanUnion(vplate1) = { Volume{vplate}; Delete;}{ Volume{vconn5}; Delete;};

vplate2 = newv;
BooleanUnion(vplate2) = { Volume{vplate1}; Delete;}{ Volume{vconn6}; Delete;};

// create a new sphere to cut
X_sphere =  x_sphere;
Y_sphere =  y_sphere;
Z_sphere =  z_sphere;
vsp = newv;
Sphere(vsp) = {X_sphere, Y_sphere, Z_sphere, sphere_radius, -Pi/4, Pi/4, 2*Pi};

vupperswash = newv;
BooleanDifference(vupperswash) = { Volume{vplate2}; Delete; }{ Volume{vsp}; Delete; };
Printf("Created upper swash volume (%g)", vupperswash);
out[] = Translate {xtrans, ytrans, ztrans} { Volume{vupperswash}; };
vupperswash = out[0];
Return
//