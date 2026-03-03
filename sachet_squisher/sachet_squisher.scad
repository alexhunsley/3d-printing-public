// sachet_squisher.scad
//
// efficiently feed your cats!

$fn = 128;

do_cutaway = false;
// enable both cutaways to see a clear profile of the V cut
do_cutaway2 = false;

slot_width = 110;
slot_y = 5;
slot_widths = [0.6, 0.9, 1.5];

squisher_depth = 3;
slot_straight_section_depth = 1;
slot_angle_section_depth = squisher_depth - slot_straight_section_depth;
// handle is a squished semi-circle
squisher_handle_smaller_radius= 30;

margin = 4;
corner_radius = 5;

text_depth = 0.4;
text_y = 5.25;

module __Customizer_Limit__ () {}

/////////////////////////////////////////////////////////////////////////////////

eps = 0.001;

size = [slot_width + 2 * margin, 35, squisher_depth];

function slot_profile_points(slot_gap) =
    mirror_poly_points_x(
        [[slot_gap/2, 0],
         [slot_gap/2, slot_straight_section_depth],
         [slot_gap/2 + slot_angle_section_depth, squisher_depth + eps*3]]
    );

module slot(slot_gap) {
    rotate([90, 0, 90])
        linear_extrude(slot_width, center=true)
            polygon(slot_profile_points(slot_gap));
}

module squisher() {
    difference() {
        union() {
            cube(size, center=true);
            translate([0, size[1]/2 - eps, -squisher_depth/2]) {
                difference() {
                    linear_extrude(squisher_depth) {
                        scale([1, squisher_handle_smaller_radius / size[0], 1])
                                circle(size[0]/2);
                    }
                    translate([0, text_y, squisher_depth - text_depth])
                        linear_extrude(text_depth + 0.1)
                            text("hunsley.io", font="Futura:style=Bold", size=7.5, halign="center", valign="center");                            
                    
                }
            }
        }            
        translate([0, -size[1]/2, -squisher_depth/2 - eps]) {
            translate([0, slot_y/2 + margin - eps, 0])
                slot(slot_widths[2]);
            translate([0, slot_y/2 * 6 + margin - eps, 0])
                slot(slot_widths[1]);
            translate([0, slot_y/2 * 11 + margin - eps, 0])
                slot(slot_widths[0]);
        }
    }
}    

module main() {
    difference() {
        cut_size = 100;
        squisher();
        if (do_cutaway) {
            translate([cut_size/2, 0, 0])
                 cube([cut_size, cut_size, 10], center=true);
            if (do_cutaway2) {
                translate([-cut_size/2 - 10, 0, 0])
                     cube([cut_size, cut_size, 10], center=true);
            }
        }
    }
}

main();


// ------------- UTIL

function mirror_poly_points_x(points) =
    concat(
        points,
        [
            for (i = [len(points) - 1 : -1 : 0])
                [-points[i][0], points[i][1]]
        ]
    );
