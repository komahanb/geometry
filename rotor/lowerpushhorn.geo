//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "naca.geo";
Include "CreateComponents.geo";

//-------------------------------------------------------------------//
//                    PUSH HORN
//-------------------------------------------------------------------//

aoffset = 0;
xloc = base_radius*Cos(aoffset) - link_length/2.0;
yloc = base_radius*Sin(aoffset) ;
zloc = z_base + base_height/2.0;
Call CreateLowerPushHorn;
vlph = NewVolume;