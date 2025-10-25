//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";

aoffset = 0;
theta = upper_swash_angle;
Call CreateMalePitchLink;
aoffset = 0;
Call CreateFemalePitchLink;