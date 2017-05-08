Function HollowCylinder
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

// Set the output volume number
NewVolume = v;

Return

//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "parameters.geo";

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
