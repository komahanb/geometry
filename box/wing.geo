Include "rae2822.geo";

// Scale the points to meet the chord
// Dilate {{0, 0, 0}, chord} { Point{1:num_points};}

// Link the airfoil coordinate points to form a spline
Spline(1) = {1:num_points,1};
Line Loop(1) = {1};
Plane Surface(1) = {1};

//Transfinite surface:
//Transfinite Surface {1};
//Recombine Surface {1};

// Rotate the airfoil to the X-Z plane and translate the airfoil to r_tw
// Rotate {{1, 0, 0}, {0, 0, 0}, Pi/2} { Surface{1};}
Translate {0, r_tw,0} { Point{1:num_points}; }

//Extrude the airfoil toward the rotor tip with negative linear twist
Extrude { {0, R-r_tw, 0}, {0,1,0} , {0,0,0} , (R-r_tw)*dtheta} {
Surface{1}; 
Layers{(R-r_tw)/cl}; 
Recombine;
}
Coherence;

//Extrude the airfoil toward the rotor hub with positive linear twist
Extrude { {0,r_cutout-r_tw,0}, {0,1,0}, {0,0,0}, (r_cutout-r_tw)*dtheta} {
 Surface{1}; 
 Layers{(r_tw-r_cutout)/cl}; 
 Recombine;
}
Coherence;

Extrude { {0,(r_cutout-r_tw)/2,0}, {0,1,0}, {0,0,0}, (r_cutout-r_tw)/2*dtheta} {
 Surface{1}; 
 Layers{(r_tw-r_cutout)/(2*cl)}; 
 Recombine;
}
Coherence;