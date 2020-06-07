SetFactory("OpenCASCADE");

// Include the parametrized inputs for geometry
Include "../Parameters.geo";

///////////////////////////////////////////////////////////////////////
//                Cylindrical Link 1   (z-rigid)                     //  
///////////////////////////////////////////////////////////////////////

xtmp   = xbaselink1;
ytmp   = ybaselink1;
ztmp   = zbaselink1;
vtmp   = newv;
dx     = 0.0;
dy     = 0.0;
dz     = length_link1;
radius = radius_link1;
Cylinder(vtmp) = {xtmp, ytmp, ztmp,
                  dx, dy, dz,
                  radius,
                  2.0*Pi};