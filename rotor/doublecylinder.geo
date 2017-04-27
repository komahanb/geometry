h1 = 0.25; // 10 times thickness
cl = 0.05;
outer_radius = 0.22 ;
inner_radius = outer_radius/2;

// Define points
Point(1) = {0, 0, 0, cl};

// Define points on the outer circumference of hub
Point(2) = {outer_radius, 0, 0, cl};
Point(3) = {0, outer_radius, 0, cl};
Point(4) = {-outer_radius, 0, 0, cl};
Point(5) = {0, -outer_radius, 0, cl};

// Define points on the inner circumference of hub
Point(6) = {inner_radius, 0, 0, cl};
Point(7) = {0, inner_radius, 0, cl};
Point(8) = {-inner_radius, 0, 0, cl};
Point(9) = {0, -inner_radius, 0, cl};

// Define quarter circles on the outer circumference
Circle(1) = {2, 1, 3};
Circle(2) = {3, 1, 4};
Circle(3) = {4, 1, 5};
Circle(4) = {5, 1, 2};

// Define quarter circles on the inner circumference
Circle(5) = {6, 1, 7};
Circle(6) = {7, 1, 8};
Circle(7) = {8, 1, 9};
Circle(8) = {9, 1, 6};

Line Loop(1) = {1, 2, 3, 4}; // outer
Line Loop(2) = {5, 6, 7, 8}; // inner

//Plane Surface(3) = {1};
//Plane Surface(4) = {2};

//Physical Line("midhub_outeredge", 1) = {1, 2, 3, 4};
//Physical Line("midhub_inneredge", 2) = {5, 6, 7, 8};//+
Plane Surface(1) = {1, 2};
//+
//Plane Surface(2) = {2};
//+
Extrude {0, 0, -1} {
  Line{7, 8, 5, 6};
}
//+
Extrude {0, 0, 0.5} {
  Line{3, 4, 1, 2};
}
