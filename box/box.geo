// python ../generate_bc.py --boundary_component=4 --bdf_file=structbox.bdf
// python ../generate_mesh.py --geometry=box.geo --mesh=structbox.bdf
// cat structbox.bdf.comp4.bc >> structbox.bdf

cutout = 0.22;
chord = 0.121;
R = 2.0;

char_len = 2.00;

y_start =  cutout*R;
y_end   =  R;
x_start =  -3.0*chord/4.0;
x_end   =   chord/4.0;

thickness_chord= 0.12;
thickness = thickness_chord*chord;

Point(1) = {x_start, y_end, 0, char_len};
Point(2) = {x_end ,  y_end, 0, char_len};
Point(3) = {x_end , y_start, 0, char_len};
Point(4) = {x_start, y_start, 0, char_len};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

Line Loop(5) = {1, 2, 3, 4}; 	
Plane Surface(6) = {5};

//Transfinite surface:
Transfinite Surface {6};
Recombine Surface {6};

surfaceVector[] = Extrude {0, 0, thickness} {
Surface{6};
Layers{1};
Recombine;
};

//surfaceVector contains in the following order:
//[0]	- front surface (opposed to source surface)
//[1] - extruded volume
//[2] - bottom surface (belonging to 1st line in "Line Loop (6)")
//[3] - right surface (belonging to 2nd line in "Line Loop (6)")
//[4] - top surface (belonging to 3rd line in "Line Loop (6)")
//[5] - left surface (belonging to 4th line in "Line Loop (6)") 
Physical Surface("front") = surfaceVector[0];
Physical Volume("internal") = surfaceVector[1];
Physical Surface("bottom") = surfaceVector[2];
Physical Surface("right") = surfaceVector[3];
Physical Surface("top") = surfaceVector[4];
Physical Surface("left") = surfaceVector[5];
Physical Surface("back") = {6};