// bug_hotel.scad

tube_len = 100;
tube_radius = 4;
tube_res = 32;

tube_spacing = tube_radius * 2;

// tube radius reduction (fitting)
tube_rr = 0.0;

// how many tubes are across the design
grid_mult = 6;

grid_repeats = 2;

total_size = grid_repeats * grid_mult * tube_spacing;

module linear_design() {
    for (idx = [0 : grid_repeats - 1]) {
        translate([idx * grid_mult * tube_spacing, 0, 0]) {
            cylinder(tube_len, tube_radius, tube_radius, $fn=tube_res, center=true);
            translate([tube_spacing * 2, 0, 0])
                cylinder(tube_len, tube_radius, tube_radius, $fn=tube_res, center=true);
        //    translate([tube_spacing * 5, 0, 0])
        //        cylinder(tube_len, tube_radius, tube_radius, $fn=tube_res);
            translate([tube_spacing * 3, 0, 0])
                cylinder(tube_len, tube_radius, tube_radius, $fn=tube_res, center=true);
        }
    }
}

module 2d_design() {
    for (idx = [0 : grid_repeats - 1]) {
        translate([0, idx * grid_mult * tube_spacing, 0]) {
            linear_design();
            translate([0, tube_spacing * 2, 0])
                linear_design();
        //    translate([0, tube_spacing * 5, 0])
        //        linear_design();
            translate([0, tube_spacing * 3, 0])
                linear_design();
        }
    }
}

translate([-total_size/2, -total_size/2, 0]) {
    2d_design();
}

rotate([0, 90, 0]) {
    translate([-total_size/2, -total_size/2, 0]) {
        translate([0, 7*tube_spacing, 0])
            scale([1, -1, 1])
                2d_design();
    }
}

translate([0, 50, 0])
rotate([90, 0, 0]) {
    translate([-total_size/2, -total_size/2, 0]) {
        translate([7*tube_spacing, 0, 0])
            scale([-1, 1, 1])
                2d_design();
    }
}
