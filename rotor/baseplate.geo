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

HCVolume   = v;
//HCSurfaces = Abs(Boundary{ Volume{HCVolume}; });
//HCLines    = Unique(Abs(Boundary{ Surface{HCSurfaces}; }));
//HCPoints   = Unique(Abs(Boundary{ Surface{HCLines   }; }));

Return

//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "parameters.geo";

x_baseplate = DefineNumber[ 0, Name "Parameters/x_baseplate" ];
y_baseplate = DefineNumber[ 0, Name "Parameters/y_baseplate" ];
z_baseplate = DefineNumber[ 0, Name "Parameters/z_baseplate" ];
inner_base_radius = DefineNumber[ shaft_radius, Name "Parameters/inner_base_radius" ];

Mesh.CharacteristicLengthMin = 0.1; 
Mesh.CharacteristicLengthMax = 0.1;

// Create the hollow cylinder for main base plate
xcy = xo+x_baseplate;
ycy = yo+y_baseplate;
zcy = zo+z_baseplate;
hcy = base_height;
rcy = inner_base_radius;
Rcy = base_radius;
angle = 2*Pi;
Call HollowCylinder;
vbp = HCVolume;
Printf("Hollow cylinder is (%g)",vbp);

// Create the hollow cylinder for main base plate
aoffset = Pi/4.0;
roffset = 0.85*base_radius;

xcy = xo + x_baseplate + roffset*Cos(aoffset);
ycy = yo + y_baseplate + roffset*Sin(aoffset);
zcy = zo + z_baseplate;
hcy = 1.25*base_height;
rcy = 0.05*base_radius;
Rcy = 0.10*base_radius;
angle = 2*Pi;
Call HollowCylinder;
vpr1 = HCVolume;
Printf("Pushrod cylinder is (%g)",vpr1);

vhol = newv;
BooleanDifference(vhol) = { Volume{vbp}; Delete;}{ Volume{vpr1}; Delete;}; // baseplatev - pushrodv
Printf("New volume is (%g)", vhol);

vtmp = newv;
BooleanUnion(vtmp) = { Volume{vhol}; Delete; }{ Volume{vpr1}; Delete; };

//vtmp = newv;
//BooleanUnion(vtmp) = { Volume{vhol}; Delete; }{ Volume{vpr1}; Delete; };

//vtmp2 = newv;
//BooleanUnion(vtmp2) = { Volume{vtmp}; Delete; }{ Volume{vbp}; Delete; };


//Printf("Union volume is (%g)", vtmp);



