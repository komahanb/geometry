Function HollowCylinderZ
//
// Function that generates a hollow cylinder
//
// The following variables need to be set at entry
// xcy   : x-coordinate of the center of base
// ycy   : y-coordinate of the center of base
// zcy   : z-coordinate of the center of base
// hcy   : height of the cylinder
// rcy   : inner radius
// Rcy   : outer radius
// angle : rotation angle 2*Pi for full cylinder
//
// On exit, the following geometrical entities are set
// HC_Points[]
// HC_

// Baseplate cylinder
xtmp = xcy;
ytmp = ycy;
ztmp = zcy;

// Generate geometrical entities
v1 = newv;
Printf("creating solid cylinder = %g", v1);
Cylinder(v1) = {xtmp, ytmp, ztmp, 0, 0, hcy, Rcy, angle};

v2 = newv;
Printf("creating solid cylinder = %g", v2);
Cylinder(v2) = {xtmp, ytmp, ztmp, 0, 0, hcy, rcy, angle};

v = newv;
Printf("Creating hollow cylinder (%g) using cylinders {%g} and {%g}", v, v1, v2);
BooleanDifference(v) = { Volume{v1}; Delete; }{ Volume{v2}; Delete; };
Coherence;

NewVolume   = v;
//HCSurfaces = Abs(Boundary{ Volume{HCVolume}; });
//HCLines    = Unique(Abs(Boundary{ Surface{HCSurfaces}; }));
//HCPoints   = Unique(Abs(Boundary{ Surface{HCLines   }; }));

Return
//
Function HollowCylinderX
//
// Function that generates a hollow cylinder
//
// The following variables need to be set at entry
// xcy   : x-coordinate of the center of base
// ycy   : y-coordinate of the center of base
// zcy   : z-coordinate of the center of base
// hcy   : height of the cylinder
// rcy   : inner radius
// Rcy   : outer radius
// angle : rotation angle 2*Pi for full cylinder
//
// On exit, the following geometrical entities are set
// HC_Points[]
// HC_

// Baseplate cylinder
xtmp = xcy;
ytmp = ycy;
ztmp = zcy;

// Generate geometrical entities
v1 = newv;
Printf("creating solid cylinder = %g", v1);
Cylinder(v1) = {xtmp, ytmp, ztmp, hcy, 0, 0, Rcy, angle};

v2 = newv;
Printf("creating solid cylinder = %g", v2);
Cylinder(v2) = {xtmp, ytmp, ztmp, hcy, 0, 0, rcy, angle};

v = newv;
Printf("Creating hollow cylinder (%g) using cylinders {%g} and {%g}", v, v1, v2);
BooleanDifference(v) = { Volume{v1}; Delete; }{ Volume{v2}; Delete; };
Coherence;

NewVolume   = v;
//HCSurfaces = Abs(Boundary{ Volume{HCVolume}; });
//HCLines    = Unique(Abs(Boundary{ Surface{HCSurfaces}; }));
//HCPoints   = Unique(Abs(Boundary{ Surface{HCLines   }; }));

Return
//
Function HollowCylinderY
//
// Function that generates a hollow cylinder
//
// The following variables need to be set at entry
// xcy   : x-coordinate of the center of base
// ycy   : y-coordinate of the center of base
// zcy   : z-coordinate of the center of base
// hcy   : height of the cylinder
// rcy   : inner radius
// Rcy   : outer radius
// angle : rotation angle 2*Pi for full cylinder
//
// On exit, the following geometrical entities are set
// HC_Points[]
// HC_

// Baseplate cylinder
xtmp = xcy;
ytmp = ycy;
ztmp = zcy;

// Generate geometrical entities
v1 = newv;
Printf("creating solid cylinder = %g", v1);
Cylinder(v1) = {xtmp, ytmp, ztmp, 0, hcy, 0, Rcy, angle};

v2 = newv;
Printf("creating solid cylinder = %g", v2);
Cylinder(v2) = {xtmp, ytmp, ztmp, 0, hcy, 0, rcy, angle};

v = newv;
Printf("Creating hollow cylinder (%g) using cylinders {%g} and {%g}", v, v1, v2);
BooleanDifference(v) = { Volume{v1}; Delete; }{ Volume{v2}; Delete; };
Coherence;

NewVolume   = v;
//HCSurfaces = Abs(Boundary{ Volume{HCVolume}; });
//HCLines    = Unique(Abs(Boundary{ Surface{HCSurfaces}; }));
//HCPoints   = Unique(Abs(Boundary{ Surface{HCLines   }; }));

Return
//
Function AddPushRodHole
//
// Function that punches a hole in the base plate for holding pushrods
// This function must be call only after generating the base plate
//
// The following variables need to be set at entry
// aoffset: angular position on the base plate where the hole is made
// roffset: radial position from the origin where the hole is made
// bladeplate_vnum: volume number of the current base plate
//
// On exit, the following geometrical entities are set
// NewVolume will contain the new volume number after the hole is made.

// Punch a hole on the base plate for pushrods

xtmp = xcy + roffset*Cos(aoffset);
ytmp = ycy + roffset*Sin(aoffset);
ztmp = zcy;
hpcy = 1.25*base_height;
rpcy = 0.05*base_radius;
Rpcy = 0.10*base_radius;
pangle = 2*Pi;

// Create a solid cylider with outer radius as dim
vtmp1 = newv;
Printf("creating solid cylinder = %g", v2);
Cylinder(vtmp1) = {xtmp, ytmp, ztmp, 0, 0, hpcy, Rpcy, pangle};

// Create a solid cylider with inner radius as dim
vtmp2 = newv;
Printf("creating solid cylinder = %g", v2);
Cylinder(vtmp2) = {xtmp, ytmp, ztmp, 0, 0, hpcy, rpcy, pangle};

// Add the baseplate with the first cylinder
vtmp3 = newv;
BooleanUnion(vtmp3) = { Volume{baseplate_vnum}; Delete; }{ Volume{vtmp1}; Delete; };

// Subtract the inner cylinder from the new volume made above
v = newv;
BooleanDifference(v) = { Volume{vtmp3}; Delete; }{ Volume{vtmp2}; Delete; };
Coherence;

// Set the output volume number
NewVolume = v;

Return

Function CutBlock
//
//
//
link_length = Rpcy;
link_radius = base_height/8.0;

xtmp = x_base + roffset*Cos(aoffset);
ytmp = y_base - link_length/2.0;
ztmp = z_base;

dxtmp = 1.0; // does not matter
dytmp = link_length;
dztmp = base_height;

vblock = newv;
Block(vblock) = {xtmp, ytmp, ztmp, dxtmp, dytmp, dztmp};

// Subtract the block from the new volume made above
v = newv;
BooleanDifference(v) = { Volume{baseplate_vnum}; Delete; }{ Volume{vblock}; Delete; };
Coherence;

baseplate_vnum = v;

// Create the hollow cylinder for main base plate
xlink = roffset + link_radius*2.0;
ylink = ytmp;
zlink = z_base + base_height/2.0;

hcy = base_height;
rcy = inner_base_radius;
Rcy = base_radius;

// Add a link along y dir
vlink = newv;
Cylinder(vlink) = {xlink, ylink, zlink, 0, link_length, 0, link_radius, angle};

// Subtract the inner cylinder from the new volume made above
v = newv;
BooleanUnion(v) = { Volume{baseplate_vnum}; Delete; }{ Volume{vlink}; Delete; };
Coherence;

Newvolume = v;

Return
//
Function PushRodX
//
// Function that generates a hollow cylinder
//
// The following variables need to be set at entry
// xbcy      : x-coordinate of the center of base
// ybcy      : y-coordinate of the center of base
// zbcy      : z-coordinate of the center of base
// hrod      : height of the cylinder
// rbase_rod : inner radius
// Rhead_rod : head radius
// angle     : rotation angle 2*Pi for full cylinder
//
// On exit, the following geometrical entities are set

// Create the body as a cylinder
vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rbase_rod, 2*Pi};
Printf("Created body pushrod cylinder = %g", vbody);

xcy   = xbcy - rbase_rod;
ycy   = ybcy;
zcy   = zbcy + hrod + 2*rbase_rod - small/2.0;
hcy   = 2*rbase_rod;
rcy   = rbase_rod;
Rcy   = Rhead_rod;
angle = 2*Pi;

// Create a head with hollow cylinder
Call HollowCylinderX;
vhead = NewVolume;

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

Return
//
//
Function PushRodY
//
// Function that generates a hollow cylinder
//
// The following variables need to be set at entry
// xbcy      : x-coordinate of the center of base
// ybcy      : y-coordinate of the center of base
// zbcy      : z-coordinate of the center of base
// hrod      : height of the cylinder
// rbase_rod : inner radius
// Rhead_rod : head radius
// angle     : rotation angle 2*Pi for full cylinder
//
// On exit, the following geometrical entities are set

// Create the body as a cylinder
vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rbase_rod, 2*Pi};
Printf("Created body pushrod cylinder = %g", vbody);

xcy   = xbcy;
ycy   = ybcy- rbase_rod;
zcy   = zbcy + hrod + 2*rbase_rod - small/2.0;
hcy   = 2*rbase_rod;
rcy   = rbase_rod;
Rcy   = Rhead_rod;
angle = 2*Pi;

// Create a head with hollow cylinder
Call HollowCylinderY;
vhead = NewVolume;

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

Return
//
//
Function PushRodZ
//
// Function that generates a hollow cylinder
//
// The following variables need to be set at entry
// xbcy      : x-coordinate of the center of base
// ybcy      : y-coordinate of the center of base
// zbcy      : z-coordinate of the center of base
// hrod      : height of the cylinder
// rbase_rod : inner radius
// Rhead_rod : head radius
// angle     : rotation angle 2*Pi for full cylinder
//
// On exit, the following geometrical entities are set

// Create the body as a cylinder
vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rbase_rod, 2*Pi};
Printf("Created body pushrod cylinder = %g", vbody);

xcy   = xbcy - rbase_rod;
ycy   = ybcy;
zcy   = zbcy + hrod + 2*rbase_rod - small/2.0;
hcy   = 2*rbase_rod;
rcy   = rbase_rod;
Rcy   = Rhead_rod;
angle = 2*Pi;

// Create a head with hollow cylinder
Call HollowCylinderZ;
vhead = NewVolume;

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

Return
//