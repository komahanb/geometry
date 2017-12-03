//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Addon.geo";

length = wing_span;
chord  = wing_chord;

// create right wing
Call Ellips;
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Volume{NewVolume};}
};
NewVolume = out[0];

// create left wing
Call Ellips;
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, -Pi/2.0} {
Volume{NewVolume};}
};
NewVolume = out[0];

