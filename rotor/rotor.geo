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

// Total number of points on the NACA airfoil
NACA4_npts = NACA4_nspl*NACA4_pps ;

NACA4_Points[] = {} ;
NACA4_Splines[] = {} ;

// The upper curve points
For i In {0:NACA4_npts}
    // Determine the location of each NACA point on the airfoil
    // generate sinusoidally spaced xpoints and determine the y points based on the NACA, 
    // z is readily available as span station

    x = 0.5*(1+Cos(i/NACA4_npts*Pi)) ;
    y = NACA4_a0*Sqrt(x) +  
        x*(NACA4_a1 + x*(NACA4_a2 + x*(NACA4_a3 + x*NACA4_a4))) ;
    p = newp ;
    L1 = 1-x ; L2 = x ;
    NACA4_len = NACA4_len_le*L1*(2*L1-1) + NACA4_len_mp*4*L1*L2 +
    	      NACA4_len_te*L2*(2*L2-1) ;
    Point(p) = {NACA4_ch*x+NACA4_le_x,          
		NACA4_le_z, 
                y*NACA4_ch*NACA4_th/20+NACA4_le_y, 
                NACA4_len} ;
    NACA4_Points[i] = p ;
EndFor

// The lower curve points
For i In {NACA4_npts+1:2*NACA4_npts-1}
    x = 0.5*(1+Cos(i/NACA4_npts*Pi)) ;
    y = NACA4_a0*Sqrt(x) + 
        x*(NACA4_a1 + x*(NACA4_a2 + x*(NACA4_a3 + x*NACA4_a4))) ;
    p = newp ; 

    L1 = 1-x ; L2 = x ;

    // Quadratic for the length scale
    NACA4_len = NACA4_len_le*L1*(2*L1-1) + NACA4_len_mp*4*L1*L2 +
    	      NACA4_len_te*L2*(2*L2-1) ;

    // Define the point with the quadratic length scale and point xyz
    Point(p) = {NACA4_ch*x+NACA4_le_x,                  
		NACA4_le_z, 
                -y*NACA4_ch*NACA4_th/20+NACA4_le_y, 
                NACA4_len} ;

    // Store into the return array
    NACA4_Points[i] = p ;
EndFor

// Lets make the splines using the points
For i In {0:2*NACA4_nspl+NACA4_pps-1}
    c = newc ;
    Spline(c) = NACA4_Points[{i*(NACA4_pps-1):(i+1)*(NACA4_pps-1)}] ;
    NACA4_Splines[i] = c ;
EndFor

// Close the spline loop logic (happens at the leading edge)
c = newc ; i = 2*NACA4_nspl+NACA4_pps ;
Spline(c) = {NACA4_Points[{i*(NACA4_pps-1):(2*NACA4_npts-1)}],
	     NACA4_Points[0]} ;

NACA4_Splines[i] = c ;

Return

Function SectionJoin

// Join two aerofoil sections (from NACA4) to form a wing surface
//
// Variables which should be set on input:
//
// SJ_step     the number of points per spline on each section (must be
//             the same for both)
// SJ_points   the list of points forming the sections
// SJ_splines  the list of splines forming the sections
// SJ_offp1, SJ_offp2  the index of the trailing edge point for the first 
//             and second section in SJ_points
// SJ_offsp1, SJ_offsp2  the index of the first spline for the first 
//             and second section in SJ_points
// SJ_n_spline the number of splines per section

c0 = newl ; s0 = c0 ;
Printf("Making trailing edge line (%g,%g)", 
       SJ_points[SJ_offp1],SJ_points[SJ_offp2]) ;
Line(c0) = {SJ_points[SJ_offp1], SJ_points[SJ_offp2]} ;

j = SJ_step-1 ;
For i In {0:SJ_n_spline-1}
    c1 = newc ;
    Printf("Making line (%g,%g)", SJ_points[SJ_offp1+j],SJ_points[SJ_offp2+j]) ;

    Line(c1) = {SJ_points[SJ_offp1+j],SJ_points[SJ_offp2+j]} ;

    c = newll ;
    Printf("Making loop (%g,%g,%g,%g)",
            SJ_splines[SJ_offsp1+i],c1,-SJ_splines[SJ_offsp2+i],-c0) ;
    Line Loop(c) = {SJ_splines[SJ_offsp1+i],c1,-SJ_splines[SJ_offsp2+i],-c0} ;
    s = news ;
    Ruled Surface(s) = {c};
    c0 = c1 ; 
    j = j + SJ_step-1 ;
EndFor

c = newll ;
Printf("Making loop (%g,%g,%g,%g)",
       SJ_splines[SJ_offsp1+SJ_n_spline],s0,
	-SJ_splines[SJ_offsp2+SJ_n_spline],-c0) ;
Line Loop(c) = {SJ_splines[SJ_offsp1+SJ_n_spline],s0,
     	        -SJ_splines[SJ_offsp2+SJ_n_spline],-c0} ;
s = news ;
Ruled Surface(s) = {c};

Return

//////////////////////////////////////////////////////////////////////
// Main program
//////////////////////////////////////////////////////////////////////

// section left chord1
Root = 0.125 ;

// Wing span m
Span = 5 ;

// Taper ratio, (Tip chord)/(Root chord)
Taper = 1.0 ;

// Leading edge sweep angle
Sweep = 0*Pi/180 ;

// Defines the mesh characteristic length
BaseLength = 0.125 ;

// Number of splines and points per spline
NACA4_nspl = 8 ;
NACA4_pps = 4 ;

// The characteristic lengths at leading, mid and trailing edges
NACA4_len_le = BaseLength/2 ;
NACA4_len_mp = BaseLength/1 ;
NACA4_len_te = BaseLength/2 ;

// Airfoil thickness
NACA4_th = 12 ;

// chord as a function of taper
NACA4_ch = Root*Taper ;

// x,y,z location of the leading edge
NACA4_le_x = Span*Sin(Sweep) ;
NACA4_le_z = 0.0 ;
NACA4_le_y = 0.0 ;

//////////////////////////////////////////////////////////////////////
// Create a section left
//////////////////////////////////////////////////////////////////////

Call NACA4 ;

// Define the left boundary surface
ll = newll ;
Line Loop(ll) = NACA4_Splines[] ;
s = news ;
Plane Surface(s) = {-ll};

points[] = NACA4_Points[] ;
splines[] = NACA4_Splines[] ;

//////////////////////////////////////////////////////////////////////
// Create a section mid
//////////////////////////////////////////////////////////////////////

// section mid chord
Root = 0.20 ;

NACA4_len_le = BaseLength/2 ;
NACA4_len_mp = BaseLength ;
NACA4_len_te = BaseLength/2 ;
NACA4_ch = Root*Taper ;
NACA4_le_x = Span*Sin(Sweep) ;
NACA4_le_z = 0.25*Span ;
NACA4_le_y = 0.0 ;

Call NACA4 ;

points[] = {points[],NACA4_Points[]} ;
splines[] = {splines[],NACA4_Splines[]} ;

//////////////////////////////////////////////////////////////////////
// Create a section right
//////////////////////////////////////////////////////////////////////

Root = 0.20 ;

NACA4_len_le = BaseLength/2 ;
NACA4_len_mp = BaseLength/1 ;
NACA4_len_te = BaseLength/2 ;
NACA4_ch = Root*Taper ;
NACA4_le_x = Span*Sin(Sweep) ;
NACA4_le_z = Span ;
NACA4_le_y = 0.0 ;

Call NACA4 ;

ll = newll ;
Line Loop(ll) = NACA4_Splines[] ;
s = news ;
Plane Surface(s) = {ll};

points[] = {points[],NACA4_Points[]} ;
splines[] = {splines[],NACA4_Splines[]} ;




npts = 2*NACA4_npts ;
nsplines = 2*NACA4_nspl+NACA4_pps ;
SJ_step = NACA4_pps ;
SJ_points[] = points[] ;
SJ_splines[] = splines[] ;
SJ_n_spline = nsplines ;

SJ_offp1 = 0 ; SJ_offp2 = npts ;
SJ_offsp1 = 0 ; SJ_offsp2 = nsplines+1 ;

Call SectionJoin ;

SJ_offp1 = npts ; SJ_offp2 = 2*npts ;
SJ_offsp1 = nsplines+1 ; SJ_offsp2 = 2*nsplines+2 ;

Call SectionJoin ;

// 1=MeshAdapt, 2=Automatic, 5=Delaunay, 6=Frontal, 7=BAMG, 8=DelQuad
//Mesh.Algorithm=8
//Mesh.ElementOrder=2
//Mesh.SubdivisionAlgorithm=1
//Mesh.Format=31 
//Mesh.BdfFieldFormat=2

