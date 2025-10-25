h1 = 0.25; // 10 times thickness
cl = 0.05;

// Define points
Point(1) = {0, 0, 0, cl};
Point(2) = {0.22, 0, 0, cl};
Point(3) = {0, 0.22, 0, cl};
Point(4) = {-0.22, 0, 0, cl};
Point(5) = {0, -0.22, 0, cl};

// Define quarter circles
Circle(1) = {2, 1, 3};
Circle(2) = {3, 1, 4};
Circle(3) = {4, 1, 5};
Circle(4) = {5, 1, 2};

Physical Line("top_hub_edge", 1) = {1, 2, 3, 4};
Line Loop(5) = {1, 2, 3, 4};
Plane Surface(6) = {5};
Physical Surface("top_hub_surface",2) = {6};
Transfinite Surface {6};
Recombine Surface {6};

// Extrude downwards
s[] = Extrude {0, 0, -h1} {
  Surface{6};
  Layers{h1/cl}; 
  Recombine;
};
Coherance;

//surfaces contains in the following order:
//[0] - front surface (opposed to source surface)
//[1] - extruded volume

//[2] - bottom surface (belonging to 1st line in "Line Loop (6)")
//[3] - right surface (belonging to 2nd line in "Line Loop (6)")
//[4] - top surface (belonging to 3rd line in "Line Loop (6)")
//[5] - left surface (belonging to 4th line in "Line Loop (6)") 
// Looking from TOP at XY plane according to gmsh convention

Physical Surface("bottom_hub_surface", 3) = s[0];
Physical Surface("lateral_surface", 4) = {s[2], s[3], s[4], s[5]};