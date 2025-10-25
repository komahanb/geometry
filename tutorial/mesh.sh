Merge "t1.geo_unrolled";
Mesh 2;
SetOrder 2;
Save Sprintf("shell-box-%03g.bdf", 0);
For i In {1:0}
  RefineMesh;
  SetOrder 2;
  Save Sprintf("shell-box-%03g.bdf", i);
EndFor

