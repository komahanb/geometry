// Origin location
xorigin = 0.0;
yorigin = 0.0;
zorigin = 0.0;

// All links have same radius
link_radius = 0.19;

// Link 1 (z-axis, rigid)
xbaselink1   = xorigin;
ybaselink1   = yorigin;
zbaselink1   = zorigin;
radius_link1 = link_radius;
length_link1 = 0.90;

// Link 2 (y-axis, flexible)
xbaselink2   = xbaselink1;
ybaselink2   = ybaselink1;
zbaselink2   = zbaselink1 + length_link1;
radius_link2 = link_radius;
length_link2 = 6.40;

// Link 3 (y-axis, flexible)
xbaselink3   = xbaselink2 + length_link2;
ybaselink3   = ybaselink2;
zbaselink3   = zbaselink2;
radius_link3 = link_radius;
length_link3 = 7.00;

// Link 4 (y-axis, rigid)
xbaselink4   = xbaselink3 + length_link3;
ybaselink4   = ybaselink3;
zbaselink4   = zbaselink3;
radius_link4 = link_radius;
length_link4 = 0.50;

// Link 5 (z-axis, rigid)
xbaselink5   = xbaselink4 + length_link4;
ybaselink5   = ybaselink4;
zbaselink5   = zbaselink4;
radius_link5 = link_radius;
length_link5 = 0.80;

// Link 6 (x-axis, rigid)
xbaselink6   = xbaselink5 + length_link5;
ybaselink6   = ybaselink5;
zbaselink6   = zbaselink5;
radius_link6 = link_radius;
length_link6 = 0.60;