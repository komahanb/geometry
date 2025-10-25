//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";

// Pushrod at 180 degrees

//-------------------------------------------------------------------//
// Create a body cylinder
//-------------------------------------------------------------------//
aoffset   = Pi;
roffset   = pushrod_roffset;

xbcy      = x_base + roffset*Cos(aoffset);
ybcy      = y_base + roffset*Sin(aoffset);
zbcy      = z_base;

hrod      = pushrod_height;
rrod      = pushrod_base_radius;

vbody = newv;
Cylinder(vbody) = {xbcy, ybcy, zbcy, 0, 0, hrod, rrod, 2*Pi};
Printf("Created body pushrod cylinder = %g", vbody);

//-------------------------------------------------------------------//
// Create a head cylinder
//-------------------------------------------------------------------//

hcy   = pushrod_inner_radius;
rcy   = pushrod_outer_radius;

xcy   = x_base + roffset*Cos(aoffset);
ycy   = y_base + roffset*Sin(aoffset)- hcy/2.0; 
zcy   = z_lower_swash + lower_swash_height/2.0 ;

vhead = newv;
Cylinder(vhead) = {xcy, ycy, zcy, 0, hcy, 0, rcy, 2*Pi};
Printf("Created head pushrod cylinder = %g", vhead);

// Unite the body and head to make the pushrod
vtot = newv;
BooleanUnion(vtot) = { Volume{vhead}; Delete; }{ Volume{vbody}; Delete; };
NewVolume = vtot;

// Punch a spherical hole on the head
//xcy   = x_base + roffset*Cos(aoffset);
//ycy   = y_base + roffset*Sin(aoffset); 
//zcy   = z_lower_swash + lower_swash_height/2.0 ;
//vspheretmp = newv;
//Sphere(vspheretmp) = {xcy, ycy, zcy, pushrod_sphere_radius, -Pi/2, Pi/2, 2*Pi};
//Printf("Punched spherical hole in pushrod = %g", vspheretmp);
//v = newv;
//BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vspheretmp}; Delete; };

// Punch a cylindrical hole on the head
hcy   = 2*pushrod_inner_radius;
rcy   = pushrod_inner_radius;
vcyltmp = newv;
Cylinder(vcyltmp) = {xcy, ycy, zcy, 0,  hcy, 0, rcy, 2*Pi};
Printf("Punched cylindrical hole in pushrod = %g", vcyltmp);
v = newv;
BooleanDifference(v) = { Volume{vtot}; Delete; }{ Volume{vcyltmp}; Delete; };
