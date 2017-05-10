SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";

Call CreateBasePlate;

//--------------------------------------------------------------------//
//------------------      PUSHRODS   ---------------------------------//
//--------------------------------------------------------------------//

Call CreatePushRod90;
Call CreatePushRod180;
Call CreatePushRod270;
