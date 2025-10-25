SetFactory("OpenCASCADE");
bar1_side = 0.016;
bar2_side = 0.016;
bar3_side = 0.008;

bar1_height = 0.12;
bar2_height = 0.24;
bar3_height = 0.12;

//-------------------------------------------------------------------//
//--------------------Second bar-------------------------------------//
//-------------------------------------------------------------------//

// Create bar 2 using block
vbar2 = newv;
Block(vbar2) = {0,
                0-bar1_side/4, 
                bar1_height-bar3_side/2,
                bar2_height, bar3_side, bar3_side };


// Specify mesh characteristics
Mesh.CharacteristicLengthExtendFromBoundary = 1; 
Mesh.CharacteristicLengthFactor = 0.2; 
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