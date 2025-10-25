// Gmsh project created on Wed May  3 17:24:57 2017
SetFactory("OpenCASCADE");
//+
Block(1) = {-0.4, -0.1, -0.6, 2, 1, 0.5};
//+
Cylinder(2) = {-0, 0.4, -0.8, 0, 0, 1, 0.25, 2*Pi};
//+
BooleanDifference{ Volume{1}; Delete; }{ Volume{2}; Delete; }
//+
radius = DefineNumber[ 0.05, Name "Parameters/radius" ];
//+
Fillet{1}{16, 18, 29, 25}{radius}
//+
Rotate {{0, 0, 1}, {1, 0, 0}, Pi/2} {
  Duplicata { Volume{1}; }
}
//+
Rotate {{0, 0, 1}, {1, 0, 0}, Pi/2} {
  Duplicata { Volume{2}; }
}
//+
Rotate {{0, 0, 1}, {1, 0, 0}, Pi/2} {
  Duplicata { Volume{3}; }
}
//+
BooleanFragments{ Volume{1}; Delete; }{ Volume{4}; Delete; }
//+
BooleanDifference{ Volume{7}; Delete; }{ Volume{6}; Delete; }
//+
BooleanFragments{ Volume{3}; Delete; }{ Volume{7}; Delete; }
//+
BooleanFragments{ Volume{2}; Volume{6}; Delete; }{ Volume{7}; Delete; }
//+
BooleanDifference{ Volume{16}; Volume{12}; Delete; }{ Volume{9}; Delete; }
//+
BooleanUnion{ Volume{14}; Delete; }{ Volume{10}; Delete; }
//+
BooleanUnion{ Volume{11}; Delete; }{ Volume{13}; Delete; }
//+
BooleanUnion{ Volume{15}; Delete; }{ Volume{18}; Delete; }
//+
BooleanUnion{ Volume{18}; Delete; }{ Volume{5}; Delete; }
//+
BooleanUnion{ Volume{18}; Delete; }{ Volume{17}; Delete; }
//+
BooleanUnion{ Volume{16}; Delete; }{ Volume{17}; Delete; }
//+
BooleanUnion{ Volume{9}; Delete; }{ Volume{8}; Delete; }
//+
BooleanUnion{ Volume{5}; Delete; }{ Volume{4}; Delete; }
//+
Coherence;
