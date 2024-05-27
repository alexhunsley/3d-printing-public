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
b = 1.5;
c = 1.5;

d = 0.5;


// wood (shelf) thickness
W = 2.8;

// gap between shelf and 'grasping' wall (on just one side)
G = -0.05;

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

total_height = T_2b + f;

base_part_height = T_2b;


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


module base_for_cutting() {
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
helper_circle_radius = 1;
helper_circle_depth = 0.3;

module main(miss_centre_beam_angles = [], miss_quarter_cut_angles = [], miss_vertical_holder_angles = []) {
    difference() {
        base_for_cutting();

        // cuts
        for (rot = [0 : 90 : 270]) {
            rotate([0, 0, rot]) {
                // the cutaways at top (the very visible ones)
                translate([0, 0, base_part_height]) {
                    // big corner cut
                    corner_cut_y_trans = in_array(rot, miss_vertical_holder_angles) ? -inf/2 : x - eps;
                    translate([x - eps, corner_cut_y_trans, 0])
                        cube(inf);
                    // cut for the upright shelf gripper
                    if (!in_array(rot, miss_centre_beam_angles)) {
                        translate([- T_1 / 2, x - x / 2 + 0.5, 0])
                            cube([T_1, inf, inf]);
                    }
                    // slope cut at 45 deg
                    translate([-inf/2, x, f])
                        rotate([-45, 0, 0])
                            cube([inf, inf, inf]);
                }
                
                // the 4 cutaways in base (more hidden)
                // big corner cut
                if (!in_array(rot, miss_quarter_cut_angles)) {
                    translate([d, d, c - G])
                        cube([inf, inf, T_2]);
                }
                
                // little notch in the 45 degree slope
                translate([- inf / 2, T_1b / 2 + pp, base_part_height + pp])
                    cube([inf, inf, inf]);
                
                // reduction cut similar to notch further after corner cut
                
//                translate([(T_1b + f)/2, (T_1b + f)/2, 0])
//                    cube(30);
            }
        }  
       
        // helper circle
        translate([0, 0, -eps])
            cylinder(h = helper_circle_depth + eps, r = helper_circle_radius, $fn = 16);
    }    
}

piece_tx = 24;

// piece 1 (entire piece)
translate([-piece_tx, 0, -eps])
    main();

// piece 2 (two quadrants)
intersection() {
    main(miss_centre_beam_angles = [90], miss_quarter_cut_angles = [90, 180]);
    translate([-T_1b / 2, -inf/2, 0])
        cube(inf);
}

// piece 3 (one quadrant)
translate([piece_tx, 0, -eps])
    intersection() {
        main(miss_centre_beam_angles = [90, 180], miss_quarter_cut_angles = [90, 180, 270]);
        translate([-T_1b / 2, -T_1b / 2, 0])
            cube(inf);
    }

// piece 4 (one quadrant, only one upright holder, not two -- for front corner (open shelf))
// piece 3 (one quadrant)

module piece4() {
    intersection() {
        main(miss_centre_beam_angles = [90, 180, 270], miss_quarter_cut_angles = [90, 180, 270],
            miss_vertical_holder_angles = [0]);
        translate([-T_1b / 2, -T_1b / 2, 0])
            cube(inf);
    }
}

//translate([2 * piece_tx, 0, -eps])
    piece4();

// piece 5 -- just piece 4 mirrored in y/z plane
translate([3 * piece_tx, 0, -eps])
    scale([-1, 1, 1])
        piece4();




translate([2 * piece_tx, 0, -eps]) {
    intersection() {
        main(miss_centre_beam_angles = [90, 180, 270], miss_quarter_cut_angles = [90, 180, 270],
            miss_vertical_holder_angles = [0]);
        translate([-T_1b / 2, -T_1b / 2, 0])
            cube(inf);
    }
    
}


echo(total_height);


// helpers
    
function in_array(value, arr) = len(search(value, arr)) > 0;
    
//let t = in_array(5, [1, 2, 5, 7]);
    
//echo("ASDasd", in_array(2, [1, 2, 5, 7]));
    
    