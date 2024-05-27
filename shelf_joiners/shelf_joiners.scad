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
a = 0.75;

// base z thicknesses
b = 1;
c = 1.25;

d = 0.5;


// wood (shelf) thickness
W = 2.8;

// gap between shelf and 'grasping' wall (on just one side)
G = 0.1;


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
// To disable, set to a large value.
pp = 2;

module main() {
    difference() {
        base_for_cutting();

        // cuts
        for (rot = [0 : 90 : 270]) {
            rotate([0, 0, rot]) {
                // the cutaways at top (the very visible ones)
                translate([0, 0, base_part_height]) {
                    // big corner cut
                    translate([x - eps, x - eps, 0])
                        cube(inf);
                    // cut for the upright shelf gripper
                    translate([- T_1 / 2, x - x / 2 + 0.5, 0])
                        cube([T_1, inf, inf]);
                    // slope cut at 45 deg
                    translate([-inf/2, x, f])
                        rotate([-45, 0, 0])
                            cube([inf, inf, inf]);
                }
                
                // the 4 cutaways in base (more hidden)
                // big corner cut
                translate([d, d, c - G])
                    cube([inf, inf, T_2]);

//                translate([- inf / 2, T_1b / 2 + f/2 - pp, base_part_height + f/2 - pp])
                translate([- inf / 2, T_1b / 2 + pp, base_part_height + pp])
                    cube([inf, inf, inf]);
                
                // reduction cut similar to notch further after corner cut
                
//                translate([(T_1b + f)/2, (T_1b + f)/2, 0])
//                    cube(30);
            }
        }  
    }    
}

piece_tx = 22;

// piece 1 (entire piece)
main();

// piece 2 (two quadrants)
translate([-piece_tx, 0, -eps])
    intersection() {
        main();
        translate([-T_1b / 2, -inf/2, 0])
            cube(inf);
    }

// piece 1 (one quadrant)
translate([piece_tx, 0, -eps])
    intersection() {
        main();
        translate([-T_1b / 2, -T_1b / 2, 0])
            cube(inf);
    }

echo(total_height);













