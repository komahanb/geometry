// Details of computation methods, see NASA TM 4741, Ladson,
// Brooks, Hill and Sproles, 1996.

Function NACA4

// Generate a symmetric NACA four series aerofoil composed of a set of
// splines
//
// The following variables must be set on entry:
// NACA4_th       : thickness in percent of chord
// NACA4_ch       : aerofoil chord
// NACA4_le_x,y,z : leading edge coordinates
// NACA4_len_te   : length scale (trailing edge)
// NACA4_len_mc   : length scale (mid chord)
// NACA4_len_le   : length scale (leading edge)
// NACA4_nspl     : number of splines on section
// NACA4_pps      : number of points per spline

// The local scale length will be set using a quadratic which interpolates
// trailing edge, midpoint and leading edge scale lengths as a function of
// distance along the chord.

// On exit, the following variables will contain the details of
// a closed NACA 00TH section with 2*NACA4_nspl splines, each of
// NACA4_pps points:
//
// NACA4_Points[] a list of the 2*NACA4_nspl*NACA4_pps points
//                on the section
// NACA4_Splines[] a list of the 2*NACA4_nspl splines
//
// These two lists are oriented so that they start at the trailing edge
// and move over the upper surface and around the lower surface to return
// to the trailing edge

// constants from NASA TM4741
NACA4_a0 =  0.2969 ;
NACA4_a1 = -0.1260 ;
NACA4_a2 = -0.3516 ;
NACA4_a3 =  0.2843 ;
NACA4_a4 = -0.1015 ;

NACA4_npts = NACA4_nspl*NACA4_pps ;

NACA4_Points[] = {} ;
NACA4_Splines[] = {} ;

my_surfaces[] = {} ;

For i In {0:NACA4_npts}
    x = 0.5*(1+Cos(i/NACA4_npts*Pi)) ;
    y = NACA4_a0*Sqrt(x) + 
        x*(NACA4_a1 + x*(NACA4_a2 + x*(NACA4_a3 + x*NACA4_a4))) ;
    p = newp ;
    L1 = 1-x ; L2 = x ;
    NACA4_len = NACA4_len_le*L1*(2*L1-1) + NACA4_len_mp*4*L1*L2 +
    	      NACA4_len_te*L2*(2*L2-1) ;
    Point(p) = {NACA4_ch*x+NACA4_le_x,  
                y*NACA4_ch*NACA4_th/20+NACA4_le_y, 
		NACA4_le_z, NACA4_len} ;
    NACA4_Points[i] = p ;
EndFor

For i In {NACA4_npts+1:2*NACA4_npts-1}
    x = 0.5*(1+Cos(i/NACA4_npts*Pi)) ;
    y = NACA4_a0*Sqrt(x) + 
        x*(NACA4_a1 + x*(NACA4_a2 + x*(NACA4_a3 + x*NACA4_a4))) ;
    p = newp ; 
    NACA4_len = NACA4_len_le*L1*(2*L1-1) + NACA4_len_mp*4*L1*L2 +
    	      NACA4_len_te*L2*(2*L2-1) ;
    Point(p) = {NACA4_ch*x+NACA4_le_x,  
                -y*NACA4_ch*NACA4_th/20+NACA4_le_y, 
		NACA4_le_z, NACA4_len} ;
    NACA4_Points[i] = p ;
EndFor

For i In {0:2*NACA4_nspl+NACA4_pps-1}
    c = newc ;
    Spline(c) = NACA4_Points[{i*(NACA4_pps-1):(i+1)*(NACA4_pps-1)}] ;
    NACA4_Splines[i] = c ;
EndFor
c = newc ; i = 2*NACA4_nspl+NACA4_pps ;

Spline(c) = {NACA4_Points[{i*(NACA4_pps-1):(2*NACA4_npts-1)}],
	     NACA4_Points[0]} ;

NACA4_Splines[i] = c ;

Return

lc = 0.1;

// Rectangular boundary points
Point(1) = {-1,-1,0,lc};
Point(2) = {-1,1,0,lc};
Point(3) = {1,-1,0,lc};
Point(4) = {1,1,0,lc};

// Make edges of rectangle
Line(1) = {1,3};
Line(2) = {3,4};
Line(3) = {4,2};
Line(4) = {2,1};

Physical Curve("Bottom") = {1};
Physical Curve("Right") = {2};
Physical Curve("Top") = {3};
Physical Curve("Left") = {4};

// Airfoil parameters
NACA4_le_x = 0.0; 
NACA4_le_y = 0.0 ;
NACA4_le_z = 0.0;
NACA4_th = 12 ;
NACA4_ch = 0.5; //m
BaseLength = 0.25 ;
NACA4_len_le = BaseLength ;
NACA4_len_mp = BaseLength ;
NACA4_len_te = BaseLength ;
NACA4_nspl = 8 ;
NACA4_pps = 4 ;

// Create Airfoil points and Curves 
Call NACA4 ;

// Line Loop(1) = {3,4,1,2,-6,-5};
// Make a loop of curves forming the 
// Curve Loop(1) = {11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
// Make the airfoil surface 
// Plane Surface(1) = {1};
Curve Loop(1) = {1,2,3,4, -13, -14, -15, -16, -17, -18, -19, -20, -21, -22, -23, -24, -25, -5, -6, -7, -8, -9, -10, -11, -12};
Plane Surface(1) = {1};
Physical Curve("Airfoil") = {13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 5, 6, 7, 8, 9, 10, 11, 12};
Physical Surface("Domain") = {1};
