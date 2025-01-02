// 
// Shelf joining pieces (3 kinds, by cutting one design)
// Alex Hunsley
//
// Based on the shelf joining piece in the set I bought online
//

// pergola (Gordon)
//

// measurement params are per page 6 on my green notebook 2024-05-27
// See screenshot "shelf_joiners_design_and_parameters.jpg"
//



// a big value for cutaways
inf = 50;

eps = 0.001;

// thickness of 'wood grasping' parts
a = 1.5;

// base z thicknesses
b = 1.25;
c = 1.5;

d = 1;


// support pillars for 'no Y gap' design
pillar_radius = 3.75;
        
// minimises the gap at back around rear and centre part walls.
// We must have a gap somewhere, for completely square pieces to work.

// wood (shelf) thickness
W = 2.8;
//W = 0.9;

// gap between shelf and 'grasping' wall (on just one side)
G = -0.1;

// protrusion of the arm grippers away from centre
f = 12.0;

// 'nobble' grip radius
//r = 0; // impl later
// 'nobble' sticking out amount
K = 0; // impl later, but this var is used currently

T_1 = 2 * (K + G) + W;
T_2 = 2 * G + W;

// same but including the 'grasping' walls
T_1b = T_1 + 2 * a;
T_2b = T_2 + b + c;


oct_short_edge = T_1 + 2 * a;

// base 'height' before bits go inwards at 45 deg
e = c + T_2 + b;


base_part_height = T_2b;
base_part_height_for_front_pieces = b;


x = T_1b / 2;
y = f + T_1b / 2;


// grip travel from body.
// this limits our grip to being cut away this amount from the wall.
// To reduce print time.
// To disable, set to 0.
enable_slope_cut = true;

// amount we spare with a cut into the 45 degree slopes
slope_cut_in_spare = 3;


oct_poly_coords = [
                    [x, y], [y, x],
                    [y, -x], [x, -y],
                    [-x, -y], [-y, -x],
                    [-y, x], [-x, y]
                  ];


module base_for_cutting(doing_front_piece = true) {
//    total_height = T_2b + f;

    height = doing_front_piece ? base_part_height_for_front_pieces : base_part_height;

    total_height = height + f;
    
    linear_extrude(height = total_height, convexity = 1, center = false) {
        polygon(oct_poly_coords);
    }
}

// de-confusion helper: cuts a circle on the side that should face up or down in final construction
helper_circle_enable = true;
helper_circle_radius = 1.5;
helper_circle_depth = 0.3;


module main(doing_front_piece = true, miss_centre_beam_angles = [], miss_quarter_cut_angles = [], no_y_gap_fix_enabled = true) {
    
    height = doing_front_piece
        ? base_part_height_for_front_pieces
        : base_part_height;
         
    use_y_offs = doing_front_piece
        ? 0 
        : no_y_gap_fix_enabled ? T_2 / 2 + d : T_2 + 0.75;
    
    difference() {
        base_for_cutting(doing_front_piece);
        
        // cuts
        for (rot = [0 : 90 : 270]) {
            rotate([0, 0, rot]) {
        
                // cut for the upright shelf gripper (v visible ones)
                if (!in_array(rot, miss_centre_beam_angles)) {
                    translate([- T_1 / 2, (x - T_1) / 2 + d, b + use_y_offs])                            
                        cube([T_1, inf, inf]);
                }

                translate([0, 0, height]) {
                                        
                    translate([x - eps, x - eps, doing_front_piece ? -c-eps : 0])
                        cube(inf);
                    // slope cut at 45 deg
                    translate([-inf/2, x, f])
                        rotate([-45, 0, 0])
                            cube([inf, inf, inf]);
                }

                // the 4 cutaways in base (more hidden)
                // big corner cut
                if (!doing_front_piece && !in_array(rot, miss_quarter_cut_angles)) {
                    translate([d, d, c - G])
                        cube([inf, inf, T_2]);
                }
                
                // little notch in the 45 degree slope
                if (enable_slope_cut) {
                    translate([- inf / 2,
                                T_1b / 2 + slope_cut_in_spare,
                                height + slope_cut_in_spare])
                        cube([inf, inf, inf]);
                }
            }
        }
        
        // helper circle on front/back face
        //  -- this isn't really needed now! It's obvious which of the parts
        // are front or back due to the cut-aways on the 45 arm bits.
        // (TODO two circles for back, one for front?)
//        translate([0, 0, -eps])
//            cylinder(h = helper_circle_depth + eps, r = helper_circle_radius, $fn = circle_segs);
    }     
    // pillars
    if (no_y_gap_fix_enabled && !doing_front_piece) {
        for (rot = [0 : 90 : 270]) {
            rotate([0, 0, rot]) {
                translate([T_1 / 2, T_1 / 2, 0])
                    quarter_cylinder(T_2b - eps, pillar_radius, res = 4);
            }
        }
    }
    
        
    // support (v thin walled cylinder)
    // -- this didn't work out so well, just do slicer support?
    // How can I make a more realistic support in the design here?
//    if (enable_support && !doing_front_piece) {
//        for (rot = [0 : 90 : 270]) {
//            rotate([0, 0, rot]) {
//                translate([support_cylinder_offset_dist, support_cylinder_offset_dist, c-eps])
//                    cylinder_hollow(h = T_2 + 1, rd = suport_cyl_r2, thickness = support_cyl_thickness, $fn = 10);
//            }
//        }
//    }
}

//module cylinder_hollow(h, rd, thickness) {
//    difference() {
//        translate([0, 0, -eps])
//            cylinder(h, r = rd, $fn = 16);
//            cylinder(h, r = rd - thickness, $fn = 16);
//    }
//}

//support_cyl_thickness = 0.4;
//
//// the temp support (to avoid having to do it repeatedly in prusa slicer):
//suport_cyl_r2 = 2.2;
//
// why will these 'support' cylinders not stick to the pieces?! They're free roaming when I do arrange.
//support_cylinder_offset_dist = 5.05;
//
// code for this currently commented out, see above
// enable_support = false;


piece_tx = 24;
circle_segs = 32;

module quarter_cylinder(h, r, res = circle_segs) {
    difference() {
        cylinder(h, r = r, $fn = res);
        translate([-inf/2, 0, 0])
            scale([1, -1, 1])
                cube([inf, inf, h + eps]);
        translate([0, -inf/2, 0])
            scale([-1, 1, 1])
                cube([inf, inf, h + eps]);
    }
}


module all_pieces(doing_front_piece = true, no_y_gap_fix_enabled = true, piece_counts = [1,1,1], piece_mult = 1) {
    displace = 32;
    echo(piece_counts);
    
//    translate([0, doing_front_piece ? 0 : piece_tx, 0]) {
        // piece 1 (entire piece) - most common
    if (piece_counts[2] > 0)
        for (p1 = [0 : piece_mult * piece_counts[2] - 1]) {
            translate([-piece_tx, p1 * displace, -eps])
                main(doing_front_piece, no_y_gap_fix_enabled = no_y_gap_fix_enabled);
        }
    
    if (piece_counts[1] > 0)
        for (p2 = [0 : piece_mult * piece_counts[1] -1]) {
            // piece 2 (two quadrants) - next most common
            translate([0, p2 * displace, 0]) {
                intersection() {
                    main(doing_front_piece, miss_centre_beam_angles = [90], miss_quarter_cut_angles = [90, 180], no_y_gap_fix_enabled = no_y_gap_fix_enabled);
                    translate([-T_1b / 2, -inf/2, 0])
                        cube(inf);
                }
            }
        }

    if (piece_counts[0] > 0)
        for (p3 = [0 : piece_mult * piece_counts[0] - 1]) {
            // piece 3 (one quadrant) - most rare
            translate([piece_tx, p3 * displace, -eps])
                intersection() {
                    main(doing_front_piece, miss_centre_beam_angles = [90, 180], miss_quarter_cut_angles = [90, 180, 270], no_y_gap_fix_enabled = no_y_gap_fix_enabled);
                    translate([-T_1b / 2, -T_1b / 2, 0])
                        cube(inf);
                }
        }
}


// We only strictly need THREE pieces!
// As long as the big flat side is facing the the user or the rear of the shelf, it works.
//
// For niceness, the user-facing pieces don't need a gap where that face is missing.
// So we need a version of all three pieces without those gap(s), so six pieces in all.
//   -- this isn't necessary now, I think, due to us cutting a bit out of the 45 degree
//      slopes.

// piece 4 (one quadrant, only one upright holder, not two -- for front corner (open shelf))


//translate([2 * piece_tx, 0, -eps])
//    intersection() {
//        main(miss_centre_beam_angles = [90, 180], miss_quarter_cut_angles = [90, 180, 270],
//            miss_vertical_holder_angles = [0]);
//        translate([-T_1b / 2, -T_1b / 2, 0])
//            cube(inf);
//    }

// piece 5 -- just piece 4 mirrored in y/z plane
//translate([3 * piece_tx, 0, -eps])
//    scale([-1, 1, 1])
//        piece4();


// some rear plates

// 100 is the wood size
panel_size = 50;
panel_thickness = W;

// a little give to help rotating and slotting in the panels
pillar_gap = 0.3;

translate([0, piece_tx, 0])
    // piece_mult = 2 doos both front and back pieces
    all_pieces(doing_front_piece = false,
                no_y_gap_fix_enabled = true,
                piece_counts = piece_counts(1, 1),
                piece_mult = 1);


function piece_counts(shelf_x_holes, shelf_y_holes)
    = [4,
    2 * (shelf_x_holes + shelf_y_holes) - 4,
    (shelf_x_holes-1) * (shelf_y_holes-1)];

// helpers
    
function in_array(value, arr) = len(search(value, arr)) > 0;

//do_panels();
//
//module do_panels() {
//    for (panel_index = [1 : 5]) {
//        translate([(panel_size + 2) * (panel_index - 0.25), 0, 0])
//            difference() {
//                cube([panel_size, panel_size, panel_thickness]);
//                // only need one notched back panel per set of panels
//                if (panel_index == 1) {
//                    union() {
//                        translate([0, 0, -eps])
//                            cylinder(panel_thickness + eps * 2, r = pillar_radius + pillar_gap, $fn = circle_segs);
//                        translate([panel_size, 0, -eps])
//                            cylinder(panel_thickness + eps * 2, r = pillar_radius + pillar_gap, $fn = circle_segs);
//                        translate([panel_size, panel_size, -eps])
//                            cylinder(panel_thickness + eps * 2, r = pillar_radius + pillar_gap, $fn = circle_segs);
//                        translate([0, panel_size, -eps])
//                            cylinder(panel_thickness + eps * 2, r = pillar_radius + pillar_gap, $fn = circle_segs);
//                    }
//                }
//            }
//    }
//}
