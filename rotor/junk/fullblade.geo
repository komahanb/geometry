// Gmsh project created on Wed May  3 17:53:11 2017
SetFactory("OpenCASCADE");

Include "parameters.geo";
Include "naca.geo";

xc = xo;
yc = yo;
zc = z_hub + hub_height/2.0 ;

dx = (2*conn_length)*Cos(conn1_angular_pos);
dy = (2*conn_length)*Sin(conn1_angular_pos);
dz = 0;

Cylinder(8) = {xc, yc, zc, dx, dy, dz, conn_radius, 2*Pi};

// Airfoil
cl       = 0.001;                        // characteristic length of the mesh //0.01
chord    = 0.121;                        // chord of the airfoil
r_cutout = 0.44;                         // cutout radius of the root
R        = 2.0;                          // Tip radius
r_tw     = 1.5;                          // radius of zero twist (m)
b_len    = R - r_cutout;                 // blade length (m)
theta_tw = -8.0;                         // linear twist (deg)
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
NACA4_le_z   = R ; // actually y

// Create the airfoil 
Call NACA4 ;

ll = newll ;
Line Loop(ll) = NACA4_Splines[] ;

s = news ;
Plane Surface(s) = {ll};
Extrude {0, -1.75, 0} {
  Surface{s}; 
  Layers{25}; 
  Recombine;
}
BooleanFragments{ Volume{9}; Delete; }{ Volume{8}; Delete; }
BooleanUnion{ Volume{2}; Delete; }{ Volume{3}; Delete; }
