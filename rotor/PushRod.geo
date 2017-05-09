Function PushRod
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
//vtot = newv;
//BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
//NewVolume = vtot;

// Rotate the pushrod as specified

Return
