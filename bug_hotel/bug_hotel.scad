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

// 1 = tube present
pattern = [1, 0, 1, 1, 0, 0];
pattern_len = len(pattern);

module linear_design(patt_offset_inner=0) {
    for (idx = [0 : grid_repeats - 1]) {
//        idx = 0;
        translate([idx * grid_mult * tube_spacing, 0, 0]) {
            
        for (i = [0 : pattern_len - 1]) {
            ii = ((i + 0) + pattern_len) % pattern_len;
            patt_idx = (ii + patt_offset_inner + pattern_len) % pattern_len;
//            ii = i;
//                echo("Checking index: ", patt_idx, " found: ", pattern[patt_idx]);
            if (pattern[ii] == 1) {
                translate([i * tube_spacing, 0, 0])
                    cylinder(tube_len, tube_radius, tube_radius, $fn=tube_res, center=true);                }
            }


//            cylinder(tube_len, tube_radius, tube_radius, $fn=tube_res, center=true);
//            translate([tube_spacing * 2, 0, 0])
//                cylinder(tube_len, tube_radius, tube_radius, $fn=tube_res, center=true);
//        //    translate([tube_spacing * 5, 0, 0])
//        //        cylinder(tube_len, tube_radius, tube_radius, $fn=tube_res);
//            translate([tube_spacing * 3, 0, 0])
//                cylinder(tube_len, tube_radius, tube_radius, $fn=tube_res, center=true);
        }
    }
}

module 2d_design(patt_offset=0, patt_offset_inner=0) {
    for (idx = [0 : grid_repeats - 1]) {
        translate([0, idx * grid_mult * tube_spacing, 0]) {
//            for (i = [patt_offset : pattern_len - 1 + patt_offset]) {
            for (i = [0 : pattern_len - 1]) {
                patt_idx = (i + patt_offset + pattern_len) % pattern_len;
//                echo("Checking index: ", patt_idx, " found: ", pattern[patt_idx]);
                if (pattern[patt_idx] == 1) {
                    translate([0, i * tube_spacing, 0])
                        linear_design(patt_offset_inner);
                }
            }
        }
    }
}

translate([-total_size/2, -total_size/2, 0]) {
    2d_design(patt_offset=0, patt_offset_inner=0);
}

rotate([0, 90, 0]) {
    scale([1, -1, 1])
    translate([-total_size/2, -total_size/2, -tube_radius*5])
        2d_design(patt_offset=1);
}
//
//
//translate([0, 50, 0])
rotate([-90, 0, 0]) {
    scale([-1, -1, 1])
        translate([-total_size/2, -total_size/2, 0]) {
        translate([5*tube_spacing, 0, 0])
            2d_design(patt_offset=1, patt_offset_inner=0);
    }
}
