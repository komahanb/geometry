Mesh.RemeshAlgorithm = 1; // automatic

Merge "tecnam.msh";

CreateTopology;
//RefineMesh;
//Coherence;

ll[] = Line "*";
For i In {0: #ll[]-1}
  Compound Line(newl) = ll[i];
EndFor

ss[] = Surface "*";
s = news;
For i In {0 : #ss[]-1}
  Compound Surface(s+i) = ss[i];
EndFor

//Physical Surface(1) = {s : s + #ss[]-1};

//Compound Surface(news) = {1};
//Physical Surface(news) = {news-1};
