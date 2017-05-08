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

//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "parameters.geo";
Include "HollowCylinder.geo";

inner_base_radius = DefineNumber[ shaft_radius, Name "Parameters/inner_base_radius" ];

// Create the hollow cylinder for main base plate
xcy = x_base;
ycy = y_base;
zcy = z_base;
hcy = base_height;
rcy = inner_base_radius;
Rcy = base_radius;
angle = 2*Pi;
Call HollowCylinder;
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