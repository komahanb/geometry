//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";

pushrod_base_radius = 0.05*base_radius;
pushrod_head_radius = 0.10*base_radius;

// Pushrod at 90 degrees
xbcy = 0;
ybcy = 0;
zbcy = 0;
hrod = 0.3*shaft_height;
rbase_rod = pushrod_base_radius;
Rhead_rod = pushrod_head_radius;

Call PushRod;