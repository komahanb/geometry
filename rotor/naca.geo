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

// Generate NACA points top surface
For i In {0:NACA4_npts}
    x = 0.5*(1+Cos(i/NACA4_npts*Pi)) ;
    y = NACA4_a0*Sqrt(x) + 
        x*(NACA4_a1 + x*(NACA4_a2 + x*(NACA4_a3 + x*NACA4_a4))) ;
    p = newp ;
    L1 = 1-x ; L2 = x ;
    NACA4_len = NACA4_len_le*L1*(2*L1-1) + NACA4_len_mp*4*L1*L2 +
    	      NACA4_len_te*L2*(2*L2-1) ;
    Point(p) = {NACA4_ch*x+NACA4_le_x,      
               	NACA4_le_z, 
                z_blade+y*NACA4_ch*NACA4_th/20+NACA4_le_y, 
                cl} ;
    NACA4_Points[i] = p ;
EndFor

// Generate points bottom surface
For i In {NACA4_npts+1:2*NACA4_npts-1}
    x = 0.5*(1+Cos(i/NACA4_npts*Pi)) ;
    y = NACA4_a0*Sqrt(x) + 
        x*(NACA4_a1 + x*(NACA4_a2 + x*(NACA4_a3 + x*NACA4_a4))) ;
    p = newp ; 
    NACA4_len = NACA4_len_le*L1*(2*L1-1) + NACA4_len_mp*4*L1*L2 +
    	      NACA4_len_te*L2*(2*L2-1) ;
    Point(p) = {NACA4_ch*x+NACA4_le_x,                 
		NACA4_le_z, 
                z_blade+-y*NACA4_ch*NACA4_th/20+NACA4_le_y, 
               cl} ;
    NACA4_Points[i] = p ;
EndFor

// Create splines from points
For i In {0:2*NACA4_nspl}
    c = newc ;
    Spline(c) = NACA4_Points[{i*(NACA4_pps-1):(i+1)*(NACA4_pps-1)}] ;
    NACA4_Splines[i] = c ;
EndFor

c = newc ; 
i = 2*NACA4_nspl+1 ; // key to correct the spacing
Spline(c) = {NACA4_Points[{i*(NACA4_pps-1):(2*NACA4_npts-1)}],
	     NACA4_Points[0]} ;
NACA4_Splines[i] = c ;

// Delete the naca points
For i In {0:NACA4_npts}
    Delete{ Point{NACA4_Points[i]}; }
EndFor
For i In {NACA4_npts+1:2*NACA4_npts-1}
    Delete{ Point{NACA4_Points[i]}; }
EndFor

Return
