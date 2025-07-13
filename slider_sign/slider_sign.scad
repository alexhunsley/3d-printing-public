// slider_sign.scad

// 3 part:
//
// bottom, top, slider
// 
// top has little tabs that insert into bottom to hold together.
//

width = 80;
height = 14;
depth = 10;

// slider fit gap in z dir
depth_gap = 0.2;

depth_slider = 1; // 1.25
depth_cover_lip = 0.5; // lip that goes over bit of slider vertically
depth_bottom = 1.0;

// internal space in 'top' for slider
//depth_top_space = depth_top - (depth_slider + depth_gap*2);
depth_top_space = depth_slider + 2 * depth_gap;

depth_top = depth_top_space + depth_cover_lip;

text = ["open", "closed"];
text_depth = 0.3;
text_size = 4.5;
text_y_adj = 1.6;

eps = 0.01;

tx = width / 2 + 3;
ty = 22;

gap = 0.1;

wall_thickness = [4, 2];

reg_dim = [0.75, height - wall_thickness[1]*2, 0];

// vertical overlap of top piece over slider (stop it falling out!)
slider_cover_vert_amount = 1.5;

grip_y_gap = 1;

slider_grip_dim = [1, height - (wall_thickness[1] + slider_cover_vert_amount + grip_y_gap)*2, 2];


module top() {
    ww = width - wall_thickness[0]*2;
    hh = height - wall_thickness[1]*2;
    
    difference() {
        cube([width, height, depth_top], center = true);
        // subtract main space for slider
        translate([0, 0, depth_top/2 - depth_slider/2 + eps])
            cube([ww, hh, depth_slider], center = true);
        // subtract window (smaller vertically so slider doesn't fall out)
       
        cube([ww, hh - slider_cover_vert_amount*2, 10], center=true);
//        slider_cover_vert_amount
    }
    
    // reg keys
    for (i = [-1 : 2 : 1]) {
        scale([i, 1, 1])
            translate([-width/2 + wall_thickness[0] - reg_dim[0]/2, 0, (depth_top + depth_bottom)/2])
                cube([reg_dim[0], reg_dim[1], depth_bottom], center=true);
    }
}

module bottom() {
    difference() {
        cube([width, height, depth_bottom], center = true);
        union() {
            // texts
            translate([-width/4, -text_y_adj, depth_bottom / 2 + eps - text_depth])
                linear_extrude(text_depth)
                    text(text[0], text_size, halign="center");
            translate([width/4, -text_y_adj, depth_bottom / 2 + eps - text_depth])
                linear_extrude(text_depth)
                    text(text[1], text_size, halign="center");
            // reg holes
            for (i = [-1 : 2 : 1]) {
                scale([i, 1, 1])
                    translate([-width/2 + wall_thickness[0] - reg_dim[0]/2, 0, 0])
                        cube([reg_dim[0], reg_dim[1], 2], center=true);
            }
        }
    }
}

module slider() {
    ww = (width - wall_thickness[0]*2 - reg_dim[0]) / 2;
    hh = height - wall_thickness[1]*2;
    translate([ww/2, 0, 0]) {
        cube([ww, hh, depth_slider], center=true);
        translate([0, 0, depth_slider/2 + slider_grip_dim[2]/2 - eps])
            // make make a cylinder knob later? or just round this rect off
            cube(slider_grip_dim, center = true);
    }
}

slider();

translate([tx, ty, 0])
    slider();

translate([tx, ty * 2, 0])
    slider();

translate([0, ty, 0])
    bottom();

translate([0, 2*ty, 0])
    top();

