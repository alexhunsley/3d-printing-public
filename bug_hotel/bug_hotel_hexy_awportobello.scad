// Parameters
points_radius = 24;       // Distance from center to each vertex
layout_radius = 24;
//wall_thickness = 5.0;
wall_thickness = 4.0;
height = 20;
// height reduced each row up
height_delta = 1.5;
corner_radius = wall_thickness / 2;

grid_size_x = 6;
grid_size_y = 3;
//grid_size_x = 2;
//grid_size_y = 2;

// Compute hexagon points (flat-top hexagon)
//points = [ for(i = [0:5]) [ 
//    points_radius * cos(60 * i),
//    points_radius * sin(60 * i)
//]];

// 1.0 = no limit
// 1.1 = 10% limit

// speed of transition at centre.
// try values > 1 like 2, 3.
// 1 means no edge limits to transformation (it begins immediately at x extremes)
no_tx_percentage_edge = 1.;

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

function transform_percentage(x, i) = (clamped_tx_percentage(x/(grid_size_x-1)) * (i == 1 || i == 3 || i == 3 || i == 5 ? 1 : 0));
//function transform_percentage(x, i) = (x/grid_size_x * (i == 3 || i == 5 ? 1 : 0));
//function transform_percentage(x, i) = 1.0;

// TODO the co-ord used being +1 for i=0,1,5
function pointsy(x, y) =
//    [ for(i = [0:5]) [ 
    [ for(i = [0:6]) [ 
//        (radius - x / 1) * cos(60 * i),
//        (radius - x / 1) * sin(60 * i)
        points_radius * cos(60 * i) - ((i % 2) == 0 ? 1 : -1) * (points_radius * 1.06 * sqrt(2.0)/3.0) * transform_percentage((x+(i == 1 || i == 5 ? 1 : 0)), i),
        points_radius * sin(60 * i)
    ]];

// Module to draw a wall between two points
module wall(p1, p2,, height) {
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
module corner(p, height) {
    translate([p[0], p[1], 0])
        cylinder(h=height, r=corner_radius, center=true, $fn=8);
}

module draw_hex(x, y, height) {
    // Draw all six walls
    pointo = pointsy(x, y);
    for (i = [0:len(pointo)-2]) {
        p1 = pointo[i];
        p2 = pointo[(i + 1) % 6];
        wall(p1, p2, height);
    }
// might not need corner cylinders - 3 walls meeting (most places) will avoid holes
    for (i = [0:len(pointo)-1]) {
        corner(pointo[i], height);
    }
}

//draw_hex();

function cell_height(x, y) = height - (grid_size_x - 1 - x) * height_delta - ((y == 1) ? 0 : 4);

module draw_hex_grid() {
    for (x = [0:grid_size_x-1]) {
        for (y = [0:grid_size_y-1]) {
            x_offset = x * 1.5 * layout_radius;
            y_offset = y * sqrt(3) * layout_radius + (x % 2) * (sqrt(3)/2 * layout_radius);
            translate([x_offset, y_offset, cell_height(x, y)/2])
                draw_hex(x, y, cell_height(x, y));
        }
    }
}

scale(0.5)
    draw_hex_grid();

