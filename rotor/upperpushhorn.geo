// 
SetFactory("OpenCASCADE");

Include "Parameters.geo";
Include "Functions.geo";
Include "CreateComponents.geo";

xloc = 0.0;
yloc = 0.0;
zloc = 0.0;

Call CreateUpperPushHorn;