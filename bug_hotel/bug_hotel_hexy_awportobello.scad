// Parameters
radius = 20;       // Distance from center to each vertex
radius2 = 20;
wall_thickness = 1;
height = 40;
corner_radius = wall_thickness / 2 + 0.1;

grid_size_x = 16;
grid_size_y = 4;
//grid_size_x = 2;
//grid_size_y = 2;

// Compute hexagon points (flat-top hexagon)
points = [ for(i = [0:5]) [ 
    radius * cos(60 * i),
    radius * sin(60 * i)
]];

// 1.0 = no limit
// 1.1 = 10% limit

// do values > 1 like 2, 3.
no_tx_percentage_edge = 3.0;

//echo(clamped_tx_percentage(0.0));
//echo(clamped_tx_percentage(0.1));
//echo(clamped_tx_percentage(0.5));
//echo(clamped_tx_percentage(0.9));
//echo(clamped_tx_percentage(1.0));

//echo(clamp(11,0,10));

echo(clamped_tx_percentage(0.0));
echo(clamped_tx_percentage(0.1));
echo(clamped_tx_percentage(0.2));
echo(clamped_tx_percentage(0.3));
echo(clamped_tx_percentage(0.5));
echo(clamped_tx_percentage(0.9));
echo(clamped_tx_percentage(1.0));


function clamp(x, minVal, maxVal) = max(minVal, min(maxVal, x));

// shrink the transform range from 0 -> 100% to A -> (100-A)%
function clamped_tx_percentage(x) = clamp(0.5 + (x - 0.5) * no_tx_percentage_edge, 0, 1);
//function clamped_tx_percentage(x) = clamp(0.5 + (x - 0.5) / no_tx_percentage_edge, 0, 1);

//function clamped_tx_percentage2(x) = 0.5 + (x - 0.5) * no_tx_percentage_edge;

function transform_percentage(x, i) = (clamped_tx_percentage(x/grid_size_x) * (i == 3 || i == 5 ? 1 : 0));
//function transform_percentage(x, i) = (x/grid_size_x * (i == 3 || i == 5 ? 1 : 0));
//function transform_percentage(x, i) = 1.0;

// TODO the co-ord used being +1 for i=0,1,5
function pointsy(x, y) =
//    [ for(i = [0:5]) [ 
    [ for(i = [2:5]) [ 
//        (radius - x / 1) * cos(60 * i),
//        (radius - x / 1) * sin(60 * i)
        radius2 * cos(60 * i) + ((i % 2) == 0 ? -1 : 1) * (radius * 2 * sqrt(2.0)/3.0) * transform_percentage((x+ (i == 5 ? 1 : 0)), i),
        radius2 * sin(60 * i)
    ]];

// Module to draw a wall between two points
module wall(p1, p2) {
    dx = p2[0] - p1[0];
    dy = p2[1] - p1[1];
    length = sqrt(dx*dx + dy*dy);
    angle = atan2(dy, dx);
    cx = (p1[0] + p2[0]) / 2;
    cy = (p1[1] + p2[1]) / 2;

    translate([cx, cy, 0])
        rotate([0, 0, angle])
            cube([length, wall_thickness, height], center=true);
}

// Module to draw a corner cylinder at a point
module corner(p) {
    translate([p[0], p[1], 0])
        cylinder(h=height, r=corner_radius, center=true, $fn=8);
}

module draw_hex(x, y) {
    // Draw all six walls
    pointo = pointsy(x, y);
    for (i = [0:len(pointo)-2]) {
        p1 = pointo[i];
        p2 = pointo[(i + 1) % 6];
        wall(p1, p2);
    }
}

//draw_hex();

module draw_hex_grid() {
    for (x = [0:grid_size_x-1]) {
        for (y = [0:grid_size_y-1]) {
            x_offset = x * 1.5 * radius;
            y_offset = y * sqrt(3) * radius + (x % 2) * (sqrt(3)/2 * radius);
            translate([x_offset, y_offset, 0])
                draw_hex(x, y);
        }
    }
}

draw_hex_grid();

// might not need corner cylinders - 3 walls meeting (most places) will avoid holes
//for (i = [0:5]) {
//    corner(points[i]);
//}
