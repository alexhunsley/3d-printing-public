// bug_hotel.scad

tube_len = 100;
tube_radius = 4;

tube_res = 32;
rot_adj_1 = 0;
rot_adj_2 = 0;
rot_adj_3 = 0;
tube_size_adj = 1;

// octagonal
//tube_res = 8;
//rot_adj_1 = 22.5;
//rot_adj_2 = 22.5;
//rot_adj_3 = 22.5;
//tube_size_adj = 1/cos(22.5);


//tube_res = 4;
//rot_adj_1 = 45;
//rot_adj_2 = 45;
//rot_adj_3 = 45;
//tube_size_adj = sqrt(2);

//tube_res = 6;
//rot_adj_1 = 30;
//rot_adj_2 = 30;
//rot_adj_3 = 0;
//tube_size_adj = sqrt(3)*2/3;

tube_wall_thickness = 1.0;
tube_inner_radius = tube_radius - tube_wall_thickness;

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

eps = 0.001;

module tube(rot_adj=0) {
    rotate([0, 0, rot_adj]) 
        scale([tube_size_adj, tube_size_adj, 1]) {
            difference() {
                cylinder(tube_len, tube_radius, tube_radius, $fn=tube_res, center=true);
                translate([0, eps, 0])
                        cylinder(tube_len + 2*eps, tube_inner_radius, tube_inner_radius, $fn=tube_res, center=true);
            }
        }
}

module linear_design(patt_offset_inner=0, rot_adj=0) {
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
                        tube(rot_adj);
                }
            }
        }
    }
}

module 2d_design(patt_offset=0, patt_offset_inner=0, rot_adj=0) {
    for (idx = [0 : grid_repeats - 1]) {
        translate([0, idx * grid_mult * tube_spacing, 0]) {
//            for (i = [patt_offset : pattern_len - 1 + patt_offset]) {
            for (i = [0 : pattern_len - 1]) {
                patt_idx = (i + patt_offset + pattern_len) % pattern_len;
//                echo("Checking index: ", patt_idx, " found: ", pattern[patt_idx]);
                if (pattern[patt_idx] == 1) {
                    translate([0, i * tube_spacing, 0])
                        linear_design(patt_offset_inner, rot_adj);
                }
            }
        }
    }
}

// Z axis
translate([-total_size/2, -total_size/2, tube_radius]) {
    2d_design(patt_offset=0, patt_offset_inner=0, rot_adj=rot_adj_1);
}

// X axis
rotate([0, 90, 0]) {
    scale([1, -1, 1])
        translate([-total_size/2, -total_size/2, -tube_radius*5])
            2d_design(patt_offset=1, rot_adj=rot_adj_2);
}

// Y axis
// rot these by 30 for hex hotel!
rotate([-90, 0, 0]) {
    scale([-1, -1, 1])
        translate([-total_size/2, -total_size/2, -tube_radius]) {
            translate([5*tube_spacing, 0, 0])
                2d_design(patt_offset=1, patt_offset_inner=0, rot_adj=rot_adj_3);
    }
}
