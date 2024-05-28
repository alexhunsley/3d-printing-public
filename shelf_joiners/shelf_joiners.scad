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


// minimises the gap at back around rear and centre part walls.
// We must have a gap somewhere, for co,pletely square pieces to work.

// wood (shelf) thickness
W = 2.8;

// gap between shelf and 'grasping' wall (on just one side)
G = -0.1;

// protrusion of the arm grippers away from centre
f = 7.75;

// 'nobble' grip radius
r = 0; // impl later
// 'nobble' sticking out amount
K = 0; // impl later

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


// amount we cut into the 45 degree slopes
slope_cut_in = 2;

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

// grip travel from body.
// this limits our grip to being cut away this amount from the wall.
// To reduce print time.
// To disable, set to 0.
enable_slope_cut = false;

pp = enable_slope_cut ? 2 : f;

// de-confusion helper: cuts a circle on the side that should face up or down in final construction
helper_circle_enable = true;
helper_circle_radius = 1.5;
helper_circle_depth = 0.3;

no_y_gap_fix_enabled = false;

module main(doing_front_piece = true, miss_centre_beam_angles = [], miss_quarter_cut_angles = []) {
    
    height = doing_front_piece ?  base_part_height_for_front_pieces : base_part_height;
         
    use_y_offs = no_y_gap_fix_enabled ? T_2 / 2 + d : T_2 + 0.5;  //- height - 0.75; // latter todo

    difference() {
        base_for_cutting(doing_front_piece);

        // cuts
        for (rot = [0 : 90 : 270]) {
            rotate([0, 0, rot]) {
                // cut for the upright shelf gripper (v visible ones)
                if (!in_array(rot, miss_centre_beam_angles)) {
                    translate([- T_1 / 2, (x - T_1) / 2 + d, c + use_y_offs])                            cube([T_1, inf, inf]);
                }

                translate([0, 0, height]) {
                    // big corner cut
//                    corner_cut_y_trans = in_array(rot, miss_vertical_holder_angles) ? -inf/2 : x - eps;
                    
                    translate([x - eps, x - eps, 0])
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
                translate([- inf / 2, T_1b / 2 + pp, height + pp])
                    cube([inf, inf, inf]);
                
                // reduction cut similar to notch further after corner cut
                
//                translate([(T_1b + f)/2, (T_1b + f)/2, 0])
//                    cube(30);
            }
        }  
       
        // helper circle on front/back face
        // (TODO two circles for back, one for front?)
        translate([0, 0, -eps])
            cylinder(h = helper_circle_depth + eps, r = helper_circle_radius, $fn = 16);
    }    
}

piece_tx = 24;

module all_pieces(doing_front_piece = true) {
    
    translate([0, doing_front_piece ? 0 : piece_tx, 0]) {
        // piece 1 (entire piece)
        translate([-piece_tx, 0, -eps])
            main(doing_front_piece);

        // piece 2 (two quadrants)
        intersection() {
            main(doing_front_piece, miss_centre_beam_angles = [90], miss_quarter_cut_angles = [90, 180]);
            translate([-T_1b / 2, -inf/2, 0])
                cube(inf);
        }

    // piece 3 (one quadrant)
    translate([piece_tx, 0, -eps])
        intersection() {
            main(doing_front_piece, miss_centre_beam_angles = [90, 180], miss_quarter_cut_angles = [90, 180, 270]);
            translate([-T_1b / 2, -T_1b / 2, 0])
                cube(inf);
        }
    }
}

all_pieces(doing_front_piece = false);
all_pieces(doing_front_piece = true);


// We only strictly need THREE pieces!
// As long as the big flat side is facing the the user or the rear of the shelf, it works.
//
// For niceness, the user-facing pieces don't need a gap where that face is missing.
// So we need a version of all three pieces without those gap(s), so six pieces in all.


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




// helpers
    
function in_array(value, arr) = len(search(value, arr)) > 0;


