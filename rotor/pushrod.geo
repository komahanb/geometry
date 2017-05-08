//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "parameters.geo";
Include "HollowCylinder.geo";
Include "PushRod.geo";

// Create the head cylinder

headrod_outer_radius = DefineNumber[ 0.1                      , Name "Parameters/headrod_outer_radius" ];
headrod_inner_radius = DefineNumber[ headrod_outer_radius/2.0 , Name "Parameters/headrod_inner_radius" ];
headrod_thickness    = DefineNumber[ headrod_outer_radius     , Name "Parameters/headrod_thickness" ];

xcy = 0.0;
ycy = 0.0;
zcy = 0.0;
hcy = headrod_thickness;
rcy = headrod_inner_radius;
Rcy = headrod_outer_radius;
angle = 2*Pi;
Call HollowCylinder;
Printf("Baseplate volume is (%g)", NewVolume);
vhead = NewVolume;

// Create the body cylinder
bodyrod_radius = DefineNumber[ headrod_thickness/2.0, Name "Parameters/bodyrod_radius" ];
bodyrod_length = DefineNumber[ 0.4*shaft_height   , Name "Parameters/bodyrod_length" ];

xbcy = 0.0;
ybcy = headrod_outer_radius-small/2.0;
zbcy = headrod_thickness/2.0;
hbcy = bodyrod_length;
rbcy = bodyrod_radius;
angle = 2*Pi;

// Generate geometrical entities
vbody = newv;
Printf("creating solid cylinder = %g", vbody);
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, hbcy,0, rbcy, angle};

vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };