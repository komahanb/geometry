SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Addon.geo";

// Main cylinder
xc   = 1.0;
yc   = 0.0;
zc   = 0.0;
hc   = 7.0;
dxc  = hc;
dyc  = 0.0;
dzc  = 0.0;
rc   = fuselage_radius;
ac   = 2*Pi;
vfuselage = newv;
Cylinder(vfuselage) = {xc, yc, zc, dxc, dyc, dzc, rc, ac};