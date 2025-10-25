//----------------------------------------------------------------//
//                    Main sequence
//----------------------------------------------------------------//

SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";

Call CreatePushRod90;
Call CreatePushRod180;
Call CreatePushRod270;