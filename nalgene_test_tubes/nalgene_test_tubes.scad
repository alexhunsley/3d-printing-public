// nalgene_test_tubes.scad

// 5x5 test tube holder:
// 12mm side of square holes (note one corner has a 45 degree diagonal inset)
// 2mm between holes
// 47mm verticxal space inside container

//show_cutaway = true;
show_cutaway = false;

//lid_in_place = true;
lid_in_place = false;

eps = 0.01;

height = 47;
//height = 7;
//height = 15;
diameter = 12.25;

base_thickess = 1;
wall_thickness = 0.4;

res = 48;
gap = 0.2;

// should be <=1 as dist between tube holders in nalgene case is 2mm
lid_pop_tab_size = 1.0;

// not including the inset-fitting part inside the tube
lid_height = 1.0;
lid_snap_bit_height = 0.75;

radius = diameter / 2;

tube_height = height - gap - lid_height;

lid_print_displace = 15;

difference() {
    main(lid_in_place);

    if (show_cutaway) {
        translate([0, -50, -1])
            cube(100, center=true);
// uncoomment this to get very thin slice
//        translate([0, 50 + 1, -1])
//            cube(100, center=true);
    }
}

module main(fit_in_place=false) {
    // main tube
    difference() {
        cylinder(tube_height, radius, radius, $fn = res);
        translate([0, 0, base_thickess])
            cylinder(tube_height, radius - wall_thickness*2, radius - wall_thickness*2, $fn = res);
    }
    
    for (lid_idx = [0 : 0]) {
        use_gap = -0.025 + 0.005 * lid_idx;
        
        inner_fit_lid_radius = radius - 2*(wall_thickness + use_gap);
        
        x_translate = fit_in_place ? 0 : lid_print_displace * (lid_idx + 1);
        z_translate = fit_in_place ? height : 0;
        z_scale = fit_in_place ? -1 : 1;
        
        translate([x_translate, 0, z_translate]) {
            // lid and snap bit
            scale([1, 1, z_scale]) {
                cylinder(lid_height, radius, radius, $fn = res);
                translate([0, 0, lid_height - eps]) {
                    cylinder(lid_snap_bit_height, inner_fit_lid_radius, inner_fit_lid_radius, $fn = res);            
                }
                // pop lid tabs
                intersection() {
                    cylinder(lid_height, radius + lid_pop_tab_size, radius + lid_pop_tab_size, $fn = res);
                    for (rot = [0 : 120 : 240]) {
                        echo(rot);
                        rotate([0, 0, rot]) {
                            translate([25, 0, lid_height/2])
                                cube([50, 4, lid_height], center=true);
                        }
                    }
                }
            
            }
        }
    }
}


