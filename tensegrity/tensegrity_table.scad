// tensegrity_table
//
// This is a square design

table_base_dim = 120;

// the center rope that supports top of the table via bottom of table
rope_length = 30;

// these lengths are the for centers of the pieces, not
// the total length!
// note that the lengths overlap, so to speak!
horiz_part_len = 20;
vert_part_len = 70;


// x_section_dim
xsd = 10;
xsd2 = xsd / 2;

// draw rope
debug = true;
//debug = false;
rope_thickness = 1;

// clearance between the bottom and top table surfaces
table_vert_gap = 2*vert_part_len - rope_length;

// -90 gives you the Ls going at 90 degs to each other
top_L_rot = 135;

module main() {
    // table bottom
    half_part(draw_ropes = true);

    // table top
    scale([-1, 1, -1])
        half_part(top_L_rot = top_L_rot);
}

main();

module rope(length) {
    color("cyan")
        cube([rope_thickness, rope_thickness, length], center = true);
}

// Both L shapes in the center.
module half_part(top_L_rot = 0, draw_ropes = false) {
    if (debug && draw_ropes) {
        rope(rope_length);

        // two ropes for one side of the base
        translate([-(table_base_dim-xsd)/2, -(table_base_dim-xsd)/2, 0])
            rope(table_vert_gap);
        
        translate([(table_base_dim-xsd)/2, -(table_base_dim-xsd)/2, 0])
            rope(table_vert_gap);
        
        translate([(table_base_dim-xsd)/2, (table_base_dim-xsd)/2, 0])
            rope(table_vert_gap);
        
        translate([-(table_base_dim-xsd)/2, (table_base_dim-xsd)/2, 0])
            rope(table_vert_gap);        
    }    

    // centre L
    rotate([90, 0, top_L_rot]) {
        linear_extrude(xsd, center = true) {
            // connected to table bottom
            half_center();

//            // connected to table top
//            rotate([0, 0, 180])
//                half_center();
        }
    }
    // the base
    translate([0, 0, rope_length / 2 - xsd2 - vert_part_len])
        cube([table_base_dim, table_base_dim, xsd], center = true);            
}

// One of the two L shapes in the center.
//
// this part is renderd relative to middle of the support rope
module half_center() {
    // horiz bar
    translate([-horiz_part_len / 2, rope_length / 2 + xsd2, 0])
        square([horiz_part_len + xsd, xsd], center = true);

    // vert bar
    translate([-horiz_part_len, rope_length / 2 + xsd2 - vert_part_len / 2, 0])
        square([xsd, vert_part_len + xsd], center = true);

    // (table surface/base has to be done outside here because
    // it's not part of the extruded center piece)    
}
