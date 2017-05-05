// Gmsh project created on Wed May  3 17:53:11 2017
SetFactory("OpenCASCADE");

Include "naca.geo";

// Root cutout radius of blade
cutout_radius = DefineNumber[ 0.44, Name "Parameters/cutout_radius" ];

// Origin of the coordinate system
xo = DefineNumber[ 0, Name "Parameters/xo" ];
yo = DefineNumber[ 0, Name "Parameters/yo" ];
zo = DefineNumber[ 0, Name "Parameters/zo" ];

// Radii of bodies normalized with respect to shaft_radius
shaft_radius       = DefineNumber[ 0.15*cutout_radius , Name "Parameters/shaft_radius" ];
upper_swash_radius = DefineNumber[ 0.50*cutout_radius , Name "Parameters/upper_swash_radius" ];
lower_swash_radius = DefineNumber[ 0.50*cutout_radius , Name "Parameters/lower_swash_radius" ];
sphere_radius      = DefineNumber[ 0.45*cutout_radius , Name "Parameters/sphere_radius" ];
hub_radius         = DefineNumber[ 0.50*cutout_radius , Name "Parameters/hub_radius" ];
base_radius        = DefineNumber[ 1.00*cutout_radius , Name "Parameters/base_radius" ];

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
z_blade       = DefineNumber[ zo+z_hub+hub_height/2.0          , Name "Parameters/z_blade" ];

conn_length       = DefineNumber[ hub_radius+(cutout_radius-hub_radius)/3.0, Name "Parameters/conn_length" ];
conn_radius       = DefineNumber[ 0.65*(0.5*hub_height), Name "Parameters/conn_radius" ];
conn1_angular_pos = DefineNumber[ Pi/2, Name "Parameters/conn1_angular_pos" ];
small             = DefineNumber[ 0.1*cutout_radius, Name "Parameters/small" ];

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
Sphere(6) = {xo, yo, zo+z_sphere, sphere_radius, -Pi/4, Pi/4, 2*Pi};

// Connector cylinder
xc = xo ;
yc = yo ;
zc = z_hub + hub_height/2.0 ;
dx = (conn_length)*Cos(conn1_angular_pos);
dy = (conn_length)*Sin(conn1_angular_pos);
dz = 0;
Cylinder(7) = {xc, yc, zc, dx, dy, dz, conn_radius, 2*Pi};


xc = xo;
yc = yo;
dx = (2*conn_length)*Cos(conn1_angular_pos);
dy = (2*conn_length)*Sin(conn1_angular_pos);
dz = 0;
Cylinder(8) = {xc, yc, zc, dx, dy, dz, conn_radius, 2*Pi};

// Airfoil
cl       = 0.01; // characteristic length of the mesh //0.01
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
NACA4_le_z   = r_cutout ; // actually y

// Create the airfoil 
Call NACA4 ;

ll = newll ;
Line Loop(ll) = NACA4_Splines[] ;

s = news ;
Plane Surface(s) = {ll};
