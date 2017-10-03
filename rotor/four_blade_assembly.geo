//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "naca.geo";
Include "CreateComponents.geo";

//--------------------------------------------------------------------//
//------------------      PUSHRODS   ---------------------------------//
//--------------------------------------------------------------------//

Call CreatePushRod90;
Call CreatePushRod180;
Call CreatePushRod270;

//-------------------------------------------------------------------//
//                    PUSH HORN
//-------------------------------------------------------------------//

aoffset = 0;
xloc = base_radius*Cos(aoffset) - link_length/2.0;
yloc = base_radius*Sin(aoffset) ;
zloc = z_base + base_height/2.0;
Call CreateLowerPushHorn;
vlph = NewVolume;

aoffset = 0;
xloc = xloc;
yloc = yloc;
zloc = z_lower_swash+ lower_swash_height/2.0;
Call CreateUpperPushHorn;
vuph = NewVolume;

//-------------------------------------------------------------------//
//------------------------ BASEPLATE --------------------------------//
//-------------------------------------------------------------------//

Call CreateBasePlate;

//-------------------------------------------------------------------//
//                         HUB
//-------------------------------------------------------------------//

Call CreateFourBladeHub;

//-------------------------------------------------------------------//
//                         SPHERE
//-------------------------------------------------------------------//

Call CreateSphere;

//-------------------------------------------------------------------//
//                    LOWER SWASH PLATE
//-------------------------------------------------------------------//

Call CreateLowerSwashPlate;

//-------------------------------------------------------------------//
//                    UPPER SWASH PLATE
//-------------------------------------------------------------------//

Call CreateUpperSwashPlate;

//-------------------------------------------------------------------//
//                    ROTOR BLADE
//-------------------------------------------------------------------//

// Create a blade at zero
Call CreateBladeX;
Call CreateBladeCapX;

// Create a blade at 180
Call CreateBladeNegativeX;
Call CreateBladeCapNegativeX;

// Create a blade at 90
Call CreateBladeY;
Call CreateBladeCapY;

// Create a blade at 270
Call CreateBladeNegativeY;
Call CreateBladeCapNegativeY;

//-------------------------------------------------------------------//
//                    PITCH LINKS
//-------------------------------------------------------------------//

theta = upper_swash_angle;
Call CreateLowerPitchLink;
vlowerpitch0 = NewVolume;

Call CreateUpperPitchLink;
vupperpitch0 = NewVolume;

// Rotate the links for +- X blades
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi} {
Duplicata{Volume{vlowerpitch0};}
};
vlowerpitch180 = out[0];

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi} {
Duplicata{Volume{vupperpitch0};}
};
vupperpitch180 = out[0];

// Rotate the links for +- Y blades
out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi/2.0} {
Duplicata{Volume{vlowerpitch0};}
};
vlowerpitch90 = out[0];

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, Pi/2.0} {
Duplicata{Volume{vupperpitch0};}
};
vupperpitch90 = out[0];

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, -Pi/2.0} {
Duplicata{Volume{vlowerpitch0};}
};
vlowerpitch270 = out[0];

out[] = Rotate {{0, 0, 1}, {xo, yo, zo}, -Pi/2.0} {
Duplicata{Volume{vupperpitch0};}
};
vupperpitch270 = out[0];