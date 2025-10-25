// python ../generate_bc.py --boundary_component=4 --bdf_file=structbox.bdf
// python ../generate_mesh.py --geometry=box.geo --mesh=structbox.bdf
// cat structbox.bdf.comp4.bc >> structbox.bdf
// https://openfoamwiki.net/index.php/2D_Mesh_Tutorial_using_GMSH#Optional:_Structured_Mesh

cutout = 0.22;
chord  = 0.121;
R = 2.0;

y_start =  cutout*R;
y_end   =  R;
x_start =  -3.0*chord/4.0;
x_end   =   chord/4.0;

thickness_chord= 0.12;
thickness = thickness_chord*chord;

char_len = 1.0;

Point(1) = { x_start , y_end   ,0.9, char_len};
Point(2) = { x_end   , y_end   ,0.9, char_len};
Point(3) = { x_end   , y_start ,0.9, char_len};
Point(4) = { x_start , y_start ,0.9, char_len};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

Line Loop(1) = {1, 2, 3, 4}; 	
Plane Surface(1) = {1};

//Transfinite surface:
Transfinite Surface {1};
Recombine Surface {1};

surfaceVector[] = Extrude {0, 0, thickness} {
Surface{1};
Layers{1};
Recombine;
};

//surfaceVector contains in the following order:
//[0] - front surface (opposed to source surface)
//[1] - extruded volume

//[2] - bottom surface (belonging to 1st line in "Line Loop (6)")
//[3] - right surface (belonging to 2nd line in "Line Loop (6)")
//[4] - top surface (belonging to 3rd line in "Line Loop (6)")
//[5] - left surface (belonging to 4th line in "Line Loop (6)") 
// Looking from TOP at XY plane according to gmsh convention

Physical Surface("front") = surfaceVector[0];
Printf("Extruding surface %d \n",1);
Printf("opposite surface number is %d\n", surfaceVector[0]);

Physical Volume("internal") = surfaceVector[1];
Physical Surface("bottom") = surfaceVector[2];
Physical Surface("right") = surfaceVector[3];
Physical Surface("top") = surfaceVector[4];
Physical Surface("left") = surfaceVector[5];
Physical Surface("back") = {1};


out[] = Rotate {{0, 0, 1}, {0, 0, 0}, Pi/2} {
Volume{surfaceVector[1]};
};
v= out[0];

Printf("Boundary surface: %g", surfaceVector[0]);

// surfaceVector2[] = Extrude {0, 0, 10.0*thickness} {
// Surface{surfaceVector[1]};
// Layers{1};
// Recombine;
// };
// 
// Physical Surface("front2") = surfaceVector2[0];
// Physical Surface("bottom2") = surfaceVector2[2];
// Physical Surface("right2") = surfaceVector2[3];
// Physical Surface("top2") = surfaceVector2[4];
// Physical Surface("left2") = surfaceVector2[5];

// Specify mesh characteristics
Mesh.CharacteristicLengthExtendFromBoundary = 1; 
Mesh.CharacteristicLengthFactor = 0.2; 
Mesh.CharacteristicLengthMin = 0; 
Mesh.CharacteristicLengthMax = 1.0; 
Mesh.CharacteristicLengthFromCurvature = 0; 
Mesh.CharacteristicLengthFromPoints = 1; 
Mesh.Optimize = 1; 
Mesh.SubdivisionAlgorithm = 1; 
Mesh.RecombinationAlgorithm = 1; 
Mesh.RecombineAll = 1; 
Mesh.RemeshAlgorithm = 0; 
Mesh.RemeshParametrization = 0; 
Mesh.RefineSteps = 10; 
Mesh.Smoothing = 5;
Mesh.ElementOrder=2; 
Mesh.BdfFieldFormat=2; 
Mesh.Format=31; 
Mesh.SaveElementTagType=1;