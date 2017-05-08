// Root cutout radius of blade
cutout_radius = DefineNumber[ 0.44, Name "Parameters/cutout_radius" ];

// Radii of bodies normalized with respect to shaft_radius
shaft_radius       = DefineNumber[ 0.15*cutout_radius , Name "Parameters/shaft_radius" ];
upper_swash_radius = DefineNumber[ 0.50*cutout_radius , Name "Parameters/upper_swash_radius" ];
lower_swash_radius = DefineNumber[ 0.50*cutout_radius , Name "Parameters/lower_swash_radius" ];
sphere_radius      = DefineNumber[ 0.45*cutout_radius , Name "Parameters/sphere_radius" ];
hub_radius         = DefineNumber[ 0.50*cutout_radius , Name "Parameters/hub_radius" ];
base_radius        = DefineNumber[ 1.00*cutout_radius , Name "Parameters/base_radius" ];

// Heights of bodies normalized with respect to shaft height
shaft_height       = DefineNumber[ 1.0              , Name "Parameters/shaft_height" ];
base_height        = DefineNumber[ 0.1*shaft_height , Name "Parameters/base_height" ];
upper_swash_height = DefineNumber[ 0.1*shaft_height , Name "Parameters/upper_swash_height" ];
lower_swash_height = DefineNumber[ 0.1*shaft_height , Name "Parameters/lower_swash_height" ];
hub_height         = DefineNumber[ 0.2*shaft_height , Name "Parameters/hub_height" ];

// Origin of the coordinate system
xo = DefineNumber[ 1, Name "Parameters/xo" ];
yo = DefineNumber[ 1, Name "Parameters/yo" ];
zo = DefineNumber[ 1, Name "Parameters/zo" ];

// z-location of the baseplate cylinder's base center
x_base        = DefineNumber[ xo + 0                                , Name "Parameters/x_base" ];
y_base        = DefineNumber[ yo + 0                                , Name "Parameters/y_base" ];
z_base        = DefineNumber[ zo + 0                                , Name "Parameters/z_base" ];

z_lower_swash = DefineNumber[ z_base + 0.4*shaft_height              , Name "Parameters/z_lower_swash" ];
z_upper_swash = DefineNumber[ z_lower_swash+lower_swash_height      , Name "Parameters/z_upper_swash" ];
z_sphere      = DefineNumber[ z_lower_swash+lower_swash_height      , Name "Parameters/z_sphere" ];
z_hub         = DefineNumber[ z_base + (1.0-hub_height)*shaft_height , Name "Parameters/z_hub" ];
z_blade       = DefineNumber[ z_base + z_hub+hub_height/2.0          , Name "Parameters/z_blade" ];

conn_length       = DefineNumber[ hub_radius+(cutout_radius-hub_radius)/3.0, Name "Parameters/conn_length" ];
conn_radius       = DefineNumber[ 0.65*(0.5*hub_height), Name "Parameters/conn_radius" ];
conn1_angular_pos = DefineNumber[ Pi/2, Name "Parameters/conn1_angular_pos" ];
small             = DefineNumber[ 0.1*cutout_radius, Name "Parameters/small" ];