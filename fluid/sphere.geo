//+
SetFactory("OpenCASCADE");
Sphere(1) = {0., 0, 0, 1, -Pi/2, Pi/2, 2*Pi};
//+
Physical Surface("boundary") = {1};
//+
Physical Volume("interior") = {1};
