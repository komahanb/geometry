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
