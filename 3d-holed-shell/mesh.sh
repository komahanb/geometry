Merge "untitled.geo";
Mesh 2;
SetOrder 2;
Save Sprintf("holed-shell-%03g.bdf", 0);
For i In {1:3}
  RefineMesh;
  SetOrder 2;
  Save Sprintf("holed-shell-%03g.bdf", i);
EndFor

