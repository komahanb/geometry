// Gmsh project created on Wed May  3 17:08:56 2017
SetFactory("OpenCASCADE");
//+
Block(1) = {-0.6, -0.1, -0.5, 2, 1, 0.5};
//+
Cylinder(2) = {0, 0.4, -0.7, 0, 0, 1, 0.5, 2*Pi};
//+
Cylinder(2) = {-0.5, 0, 0.5, 0, 0, 1, 0.5, 2*Pi};
//+
Cylinder(3) = {0.5, 0, 0.5, 0, 0, 1, 0.5, 2*Pi};
