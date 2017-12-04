//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Addon.geo";

xbase = xtailbase;
ybase = ytailbase;
zbase = ztailbase;
chord = tail_chord;
dx = xref - xtailbase;
dy = 0.0;
dz = tail_span/2.0;
Call Ellips;
v1 = NewVolume;

xbase = xref - tail_chord/2.0;
ybase = ytailbase;
zbase = ztailbase;
chord = tail_chord;
dx = 0.0;
dy = 0.0;
dz = tail_span/2.0;
Call Ellips;
v2 = NewVolume;

// v2-v1 is what we need
vtail = newv;
BooleanDifference(vtail = { Volume{v2}; Delete; }{ Volume{v1}; Delete; };

// Add a cylindrical piece to tail end
vtmp = newv;
Cylinder(vtmp) = {xbase, ybase, zbase, 1.2*tail_chord, tail_span/2.0, 0, 1.5*0.1*tail_chord, 2*Pi};

// Union with tail piece
vtail2 = newv;
BooleanUnion(vtail2) = { Volume{vtmp}; Delete;}{ Volume{vtail}; Delete;};

// Finally rotate to 45 degrees
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, -Pi/4.0} {
Volume{vtail2};}
};
NewVolume = out[0];

// Now rotate each by 90 degrees for tail parts