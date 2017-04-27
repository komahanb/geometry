h1 = 0.25; // 10 times thickness
cl = 0.05;
//+
Point(1) = {0, 0, 0, cl};
//+
Point(2) = {0.22, 0, 0, cl};
//+
Point(3) = {0, 0.22, 0, cl};
//+
Point(4) = {-0.22, 0, 0, cl};
//+
Point(5) = {0, -0.22, 0, cl};
//+
Circle(1) = {2, 1, 3};
//+
Circle(2) = {3, 1, 4};
//+
Circle(3) = {4, 1, 5};
//+
Circle(4) = {5, 1, 2};
//+
Physical Line("top_hub_edge", 1) = {1, 2, 3, 4};
//+
Line Loop(5) = {1, 2, 3, 4};
//+
Plane Surface(6) = {5};
//+
Physical Surface("top_hub_surface",2) = {6};

Transfinite Surface {6};
Recombine Surface {6};

//+
Extrude {0, 0, -h1} {
  Surface{6};
  Layers{h1/cl}; 
  Recombine;
}
Coherance;
