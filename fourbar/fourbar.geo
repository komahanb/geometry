SetFactory("OpenCASCADE");
bar1_side = 0.016;
bar2_side = 0.016;
bar3_side = 0.008;

bar1_height = 0.12;
bar2_height = 0.24;
bar3_height = 0.12;

// Define the first revolute con location
prev1 = newp;
Point(prev1) = {0.0, 0.0, 0.0};
Printf("rev1 coordinates %f %f %f", Point{prev1});

//-------------------------------------------------------------------//
//--------------------First  bar-------------------------------------//
//-------------------------------------------------------------------//

// Create bar 1 using block
vbar1 = newv;
Block(vbar1) = {0-bar1_side/2, 0-bar1_side/2, 0, 
             bar1_side, bar1_side, bar1_height};

// Second rev constraint location
prev2 = newp;
Point(prev2) = {0.0, 0.0, bar1_height};
Printf("rev2 coordinates %f %f %f", Point{prev2});

// Define the fourth revolute con location
prev4 = newp;
Point(prev4) = {bar2_height, 0.0, 0.0};
Printf("rev4 coordinates %f %f %f", Point{prev4});

//-------------------------------------------------------------------//
//--------------------Second bar-------------------------------------//
//-------------------------------------------------------------------//

// Create bar 2 using block
vbar2 = newv;
Block(vbar2) = {0,
                0-bar1_side/4, 
                bar1_height-bar3_side/2,
                bar2_height, bar3_side, bar3_side };

//-------------------------------------------------------------------//
//--------------------Third bar-------------------------------------//
//-------------------------------------------------------------------//

// Third rev constraint location
prev3 = newp;
Point(prev3) = {bar2_height, 0.0, bar3_height};
Printf("rev3 coordinates %f %f %f", Point{prev3});

// Create bar 3 using block
vbar3 = newv;
Block(vbar3) = {bar2_height-bar3_side/2, 
                0-bar3_side/2, 
                0, 
                bar3_side, bar3_side, bar3_height};

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