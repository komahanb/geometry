// Define four points that form a plate
h = 0.05;
z = 0;
Point(1) = {0,0,z,h};
Point(2) = {1,0,z,h};
Point(3) = {1,1,z,h};
Point(4) = {0,1,z,h};

// Define line from points
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// Make a loop of lines
Line Loop(1) = {1, 2, 3, 4};

//+
Plane Surface(1) = {1};

Physical Surface(1) = 1;
