// Parameters
radius = 20;       // Distance from center to each vertex
wall_thickness = 1;
height = 40;
corner_radius = wall_thickness / 2 + 0.1;

// Compute hexagon points (flat-top hexagon)
points = [ for(i = [0:5]) [ 
    radius * cos(60 * i),
    radius * sin(60 * i)
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

module draw_hex() {
    // Draw all six walls
    for (i = [0:5]) {
        p1 = points[i];
        p2 = points[(i + 1) % 6];
        wall(p1, p2);
    }
}

//draw_hex();
for (y = [0:2]) {
    for (x = [0:2]) {
        x_offset = x * 1.5 * radius;
        y_offset = y * sqrt(3) * radius + (x % 2) * (sqrt(3)/2 * radius);
        translate([x_offset, y_offset, 0])
            draw_hex();
    }
}

// might not need corner cylinders - 3 walls meeting (most places) will avoid holes
//for (i = [0:5]) {
//    corner(points[i]);
//}
