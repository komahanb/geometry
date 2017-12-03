SetFactory("OpenCASCADE");

// span is the reference length
span = 10.0;

ref = 0.8*span;

// Main cylinder
xc   = 0.0;
yc   = 0.0;
zc   = 0.0;
hc   = 0.5*ref;
dxc  = xc + hc;
dyc  = 0.0;
dzc  = 0.0;
rc   = 0.1*ref;
ac   = 2*Pi;
vcyl = newv;
Cylinder(vcyl) = {xc, yc, zc, dxc, dyc, dzc, rc, ac};

// Tail cone
htcone = 0.3*ref;
xtcone = xc + hc;
ytcone = yc;
ztcone = zc;
dxtcone = htcone;
dytcone = 0.0;
dztcone = 0.0;
r1tcone = rc;
r2tcone = 0.3*rc;
atcone  = ac;
vtcone = newv;
Cone(vtcone) = {xtcone, ytcone, ztcone, dxtcone, dytcone, dztcone, r1tcone, r2tcone, atcone};

// Head cone
hhcone = 0.1*ref;;
xhcone = xc;
yhcone = yc;
zhcone = zc;
dxhcone = -hhcone;
dyhcone = 0.0;
dzhcone = 0.0;
r1hcone = rc;
r2hcone = 0.3*rc;
ahcone  = ac;
vhcone = newv;
Cone(vhcone) = {xhcone, yhcone, zhcone, dxhcone, dyhcone, dzhcone, r1hcone, r2hcone, ahcone};