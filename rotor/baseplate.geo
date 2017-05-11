SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";

Call CreateBasePlate;

//--------------------------------------------------------------------//
//------------------      PUSHRODS   ---------------------------------//
//--------------------------------------------------------------------//

Call CreatePushRod90;
Call CreatePushRod180;
Call CreatePushRod270;

//--------------------------------------------------------------------//
//------------------      PUSHHORN   ---------------------------------//
//--------------------------------------------------------------------//

aoffset = 0;
xloc = base_radius*Cos(aoffset) - link_length/2.0;
yloc = base_radius*Sin(aoffset) ;
zloc = z_base + base_height/2.0;

Call CreateLowerPushHorn;
vlph = NewVolume;

aoffset = 0;
xloc = xloc;
yloc = yloc;
zloc = zloc + horn_length;

Call CreateUpperPushHorn;
vuph = NewVolume;

//-------------------------------------------------------------------//
//                    LOWER SWASH PLATE
//-------------------------------------------------------------------//

Call CreateLowerSwashPlate;