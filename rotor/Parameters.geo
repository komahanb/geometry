// Root cutout radius of blade
cutout_radius = DefineNumber[ 0.44, Name "Parameters/cutout_radius" ];

// Radii of bodies normalized with respect to shaft_radius

// Heights of bodies normalized with respect to shaft height
shaft_height       = DefineNumber[ 1.0              , Name "Parameters/shaft_height" ];
sphere_radius      = DefineNumber[ 0.2*shaft_height , Name "Parameters/sphere_radius" ];
base_height        = DefineNumber[ 0.1*shaft_height , Name "Parameters/base_height" ];
hub_height         = DefineNumber[ 0.2*shaft_height , Name "Parameters/hub_height" ];

upper_swash_radius = DefineNumber[ 1.4*sphere_radius , Name "Parameters/upper_swash_radius" ];
lower_swash_radius = DefineNumber[ 1.2*sphere_radius , Name "Parameters/lower_swash_radius" ];

shaft_radius       = DefineNumber[ 0.15*cutout_radius , Name "Parameters/shaft_radius" ];
hub_radius         = DefineNumber[ 0.50*cutout_radius , Name "Parameters/hub_radius" ];
base_radius        = DefineNumber[ 1.00*cutout_radius , Name "Parameters/base_radius" ];

lower_swash_height = DefineNumber[ 0.2*sphere_radius, Name "Parameters/lower_swash_height" ];
upper_swash_height = DefineNumber[ 1.5*lower_swash_height, Name "Parameters/upper_swash_height" ];

// Origin of the coordinate system
xo = DefineNumber[ 0, Name "Parameters/xo" ];
yo = DefineNumber[ 0, Name "Parameters/yo" ];
zo = DefineNumber[ 0, Name "Parameters/zo" ];

// z-location of the baseplate cylinder's base center
x_base        = DefineNumber[ xo + 0                                , Name "Parameters/x_base" ];
y_base        = DefineNumber[ yo + 0                                , Name "Parameters/y_base" ];
z_base        = DefineNumber[ zo + 0                                , Name "Parameters/z_base" ];

z_sphere      = DefineNumber[ z_base + 0.4*shaft_height , Name "Parameters/z_sphere" ];
z_lower_swash = DefineNumber[ z_sphere - lower_swash_height , Name "Parameters/z_lower_swash" ];
z_upper_swash = DefineNumber[ z_lower_swash + lower_swash_height, Name "Parameters/z_upper_swash" ];

z_hub         = DefineNumber[ z_base + (1.0-hub_height)*shaft_height , Name "Parameters/z_hub" ];
z_blade       = DefineNumber[ z_base + z_hub+hub_height/2.0          , Name "Parameters/z_blade" ];

y_lower_swash = DefineNumber[ y_base, Name "Parameters/y_lower_swash" ];
y_upper_swash = DefineNumber[ y_base, Name "Parameters/y_upper_swash" ];
y_sphere      = DefineNumber[ y_base, Name "Parameters/y_sphere" ];
y_hub         = DefineNumber[ y_base, Name "Parameters/y_hub" ];
y_blade       = DefineNumber[ y_base, Name "Parameters/y_blade" ];

x_lower_swash = DefineNumber[ x_base, Name "Parameters/x_lower_swash" ];
x_upper_swash = DefineNumber[ x_base, Name "Parameters/x_upper_swash" ];
x_sphere      = DefineNumber[ x_base, Name "Parameters/x_sphere" ];
x_hub         = DefineNumber[ x_base, Name "Parameters/x_hub" ];
x_blade       = DefineNumber[ x_base, Name "Parameters/x_blade" ];

conn_length       = DefineNumber[ hub_radius+(cutout_radius-hub_radius)/3.0, Name "Parameters/conn_length" ];
conn_radius       = DefineNumber[ 0.65*(0.5*hub_height), Name "Parameters/conn_radius" ];
conn1_angular_pos = DefineNumber[ Pi/2, Name "Parameters/conn1_angular_pos" ];
small             = DefineNumber[ 0.1*cutout_radius, Name "Parameters/small" ];

inner_base_radius = DefineNumber[ shaft_radius, Name "Parameters/inner_base_radius" ];

fillet_radius = DefineNumber[ 0.1, Name "Parameters/fillet_radius" ];


// 
pushrod_inner_radius   = 0.2*shaft_radius; // arbitrary choice
pushrod_outer_radius   = 2.0*pushrod_inner_radius; //arbitrary choice

pushrod_base_radius    = pushrod_inner_radius;
pushrod_sphere_radius  = 1.5*pushrod_inner_radius;
pushrod_height         = z_lower_swash + lower_swash_height/2.0;
pushrod_roffset        = 0.91*base_radius; // tight dependency based on where the connector links are located

link_length = 6.0*pushrod_inner_radius;
link_radius = pushrod_inner_radius;