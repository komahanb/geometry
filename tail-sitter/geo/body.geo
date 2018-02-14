SetFactory("OpenCASCADE");

Include "../Parameters.geo";
Include "../Addon.geo";
Include "../fuselage.geo";

///////////////////////////////////////////////////////////////////////
//                    Fuselage and wing                              //
///////////////////////////////////////////////////////////////////////

xbase = xwingbase;
ybase = ywingbase;
zbase = zwingbase;
chord = wing_chord;
dx = 0.0;
dy = 0.0;
dz = wing_span/2.0;

// create an ellipsoid
Call Ellips;

// Remove the fuselage from this wing
vlwing = newv;
BooleanDifference(vlwing) = { Volume{NewVolume}; Delete; }{ Volume{vfuselage}; };

out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi/2.0} {
Volume{vlwing};
};
NewVolume = out[0];
vlwing = NewVolume;

// right wing
out[] = Rotate {{1, 0, 0}, {xbase, ybase, zbase}, Pi} {
Duplicata{ Volume{vlwing}; }
};
vrwing = out[0];

// combine two wings and fuselage
vbody = newv;
BooleanUnion(vbody) = { Volume{vfuselage}; Delete;}{ Volume{vlwing}; Delete;};

vbody1 = newv;
BooleanUnion(vbody1) = { Volume{vbody}; Delete;}{ Volume{vrwing}; Delete;};

// Specify mesh characteristics
Mesh.CharacteristicLengthExtendFromBoundary = 1; 
Mesh.CharacteristicLengthFactor = 0.5; 
Mesh.CharacteristicLengthMin = 0; 
Mesh.CharacteristicLengthMax = 1.0; 
Mesh.CharacteristicLengthFromCurvature = 0; 
Mesh.CharacteristicLengthFromPoints = 1; 
Mesh.Optimize = 1; 
Mesh.SubdivisionAlgorithm = 1; 
Mesh.RecombinationAlgorithm = 1; 
Mesh.RecombineAll = 1; 
Mesh.RemeshAlgorithm = 0; 
Mesh.RemeshParametrization = 0; 
Mesh.RefineSteps = 10; 
Mesh.Smoothing = 5;
Mesh.ElementOrder=2; 
Mesh.BdfFieldFormat=2; 
Mesh.Format=31; 
Mesh.SaveElementTagType=1;
