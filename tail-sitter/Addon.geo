Function Ellips
xtmp = xbase;
ytmp = ybase;
ztmp = zbase;
thick = 0.1*chord;
angle = 2*Pi;
c = newc; 
Ellipse(c) = {xtmp, ytmp, ztmp, chord, thick, 0.0, angle};
ll = newll; 
Line Loop(ll) = {c};
s = news; 
Plane Surface(s) = {ll};
out[] = Extrude {dx, dy, dz} { Surface{s}; };
NewVolume = out[1];
Printf("created ellipsoid volume = %g", NewVolume);
Return
//