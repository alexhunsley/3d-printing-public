// Parameters
radius = 20;       // Distance from center to each vertex
radius2 = 20;
wall_thickness = 1;
height = 40;
corner_radius = wall_thickness / 2 + 0.1;

grid_size_x = 8;
grid_size_y = 3;
//grid_size_x = 2;
//grid_size_y = 2;

// Compute hexagon points (flat-top hexagon)
points = [ for(i = [0:5]) [ 
    radius * cos(60 * i),
    radius * sin(60 * i)
]];

// TODO the co-ord used being +1 for i=0,1,5
function pointsy(x, y) =
//    [ for(i = [0:5]) [ 
    [ for(i = [2:5]) [ 
//        (radius - x / 1) * cos(60 * i),
//        (radius - x / 1) * sin(60 * i)
        radius2 * cos(60 * i) + ((i % 2) == 1 ? 1 : -1) * (radius * sqrt(2.0)/3.0) * ((x+(i == 5 ? 1 : 0))/grid_size_x),
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
for (x = [0:grid_size_x-1]) {
    for (y = [0:grid_size_y-1]) {
        x_offset = x * 1.5 * radius;
        y_offset = y * sqrt(3) * radius + (x % 2) * (sqrt(3)/2 * radius);
        translate([x_offset, y_offset, 0])
            draw_hex(x, y);
    }
}

// might not need corner cylinders - 3 walls meeting (most places) will avoid holes
//for (i = [0:5]) {
//    corner(points[i]);
//}
