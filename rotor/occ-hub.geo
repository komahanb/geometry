// Gmsh project created on Wed May  3 17:53:11 2017
SetFactory("OpenCASCADE");
hub_radius = DefineNumber[ 0.3, Name "Parameters/hub_radius" ];
//+
upper_swash_radius = DefineNumber[ 0.3, Name "Parameters/upper_swash_radius" ];
//+
lower_swash_radius = DefineNumber[ 3.0*upper_swash_radius, Name "Parameters/lower_swash_radius" ];
//+
sphere_radius = DefineNumber[ 0.75*upper_swash_radius, Name "Parameters/sphere_radius" ];
//+
shaft_radius = DefineNumber[ 0.25*hub_radius, Name "Parameters/shaft_radius" ];
//+
base_radius = DefineNumber[ 0.6, Name "Parameters/base_radius" ];
//+
shaft_height = DefineNumber[ 1.0, Name "Parameters/shaft_height" ];
//+
base_height = DefineNumber[ 0.1*shaft_height, Name "Parameters/base_height" ];
//+
upper_swash_height = DefineNumber[ 0.1*shaft_height, Name "Parameters/upper_swash_height" ];
//+
lower_swash_height = DefineNumber[ 0.1*shaft_height, Name "Parameters/lower_swash_height" ];
//+
hub_height = DefineNumber[ 0.2*shaft_height, Name "Parameters/hub_height" ];
//+
xo = DefineNumber[ 0, Name "Parameters/xo" ];
//+
yo = DefineNumber[ 0, Name "Parameters/yo" ];
//+
zo = DefineNumber[ 0, Name "Parameters/zo" ];
//+
z_base = DefineNumber[ 0, Name "Parameters/z_base" ];
//+
z_lower_swash = DefineNumber[ 0.2*shaft_height, Name "Parameters/z_lower_swash" ];
//+
z_upper_swash = DefineNumber[ z_lower_swash+lower_swash_height, Name "Parameters/z_upper_swash" ];
//+
z_sphere = DefineNumber[ z_lower_swash+lower_swash_height, Name "Parameters/z_sphere" ];
//+
z_hub = DefineNumber[ (1.0-hub_height)*shaft_height, Name "Parameters/z_hub" ];
