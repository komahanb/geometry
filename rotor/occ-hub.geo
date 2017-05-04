// Gmsh project created on Wed May  3 17:53:11 2017
SetFactory("OpenCASCADE");

// Origin of the coordinate system
xo = DefineNumber[ 0, Name "Parameters/xo" ];
yo = DefineNumber[ 0, Name "Parameters/yo" ];
zo = DefineNumber[ 0, Name "Parameters/zo" ];

// Radii of bodies normalized with respect to shaft_radius
shaft_radius       = DefineNumber[ 0.15                    , Name "Parameters/shaft_radius" ];
upper_swash_radius = DefineNumber[ 2.50*shaft_radius       , Name "Parameters/upper_swash_radius" ];
lower_swash_radius = DefineNumber[ 2.50*shaft_radius       , Name "Parameters/lower_swash_radius" ];
sphere_radius      = DefineNumber[ 2.00*shaft_radius       , Name "Parameters/sphere_radius" ];
hub_radius         = DefineNumber[ 2.50*shaft_radius       , Name "Parameters/hub_radius" ];
base_radius        = DefineNumber[ 4.00*shaft_radius       , Name "Parameters/base_radius" ];

// Heights of bodies normalized with respect to shaft height
shaft_height       = DefineNumber[ 1.0              , Name "Parameters/shaft_height" ];
base_height        = DefineNumber[ 0.1*shaft_height , Name "Parameters/base_height" ];
upper_swash_height = DefineNumber[ 0.1*shaft_height , Name "Parameters/upper_swash_height" ];
lower_swash_height = DefineNumber[ 0.1*shaft_height , Name "Parameters/lower_swash_height" ];
hub_height         = DefineNumber[ 0.2*shaft_height , Name "Parameters/hub_height" ];

// z-location different bodies
z_base        = DefineNumber[ 0                                , Name "Parameters/z_base" ];
z_lower_swash = DefineNumber[ 0.4*shaft_height                 , Name "Parameters/z_lower_swash" ];
z_upper_swash = DefineNumber[ z_lower_swash+lower_swash_height , Name "Parameters/z_upper_swash" ];
z_sphere      = DefineNumber[ z_lower_swash+lower_swash_height , Name "Parameters/z_sphere" ];
z_hub         = DefineNumber[ (1.0-hub_height)*shaft_height    , Name "Parameters/z_hub" ];

// Shaft cylinder
Cylinder(1) = {xo, yo, zo, 0, 0, shaft_height, shaft_radius, 2*Pi};

// Baseplate cylinder
Cylinder(2) = {xo, yo, zo, 0, 0, base_height, base_radius, 2*Pi};

// Lower swash plate cylinder
Cylinder(3) = {xo, yo, zo+z_lower_swash, 0, 0, lower_swash_height, lower_swash_radius, 2*Pi};

// Upper swash plate cylinder
Cylinder(4) = {xo, yo, zo+z_upper_swash, 0, 0, upper_swash_height, upper_swash_radius, 2*Pi};

// Hub cylinder
Cylinder(5) = {xo, yo, zo+z_hub, 0, 0, hub_height, hub_radius, 2*Pi};

// Sphere
Sphere(6) = {xo, yo, zo+z_sphere, 0.3, -Pi/4, Pi/4, 2*Pi};