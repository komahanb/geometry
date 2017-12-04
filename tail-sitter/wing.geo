//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Addon.geo";

xbase = xwingbase;
ybase = ywingbase;
zbase = zwingbase;
chord = wing_chord;
dx = 0.0;
dy = 0.0;
dz = wing_span/2.0;

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

