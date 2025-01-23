// 5x4x3 Axial Flux Motor Design with Halbach Array
D_out = 200;    // Outer diameter in mm
D_in = 100;     // Inner diameter in mm
h_stator = 10;  // Stator height in mm
N_slots = 12;   // Slots per stator
air_gap = 2;    // Air gap between stator and rotor
$fn = 150;      // Facet resolution

// Magnet parameters
N_magnets = 16;     // Number of magnets in Halbach array
magnet_width = 15;  // Width of each magnet
magnet_height = air_gap;
magnet_depth = (D_out - D_in) / 2 - 5;  // Leaving margin for structural support

// Derived measurements
total_height = (5 * h_stator) + (4 * air_gap);

module stator() {
    difference() {
        cylinder(h=h_stator, d=D_out-1, center=true);
        //cylinder(h=h_stator, d=D_out+25, center=true);
        cylinder(h=h_stator+1, d=D_in+1, center=true);
        
        // Create slots
        for(i = [0:N_slots-1]) {
            rotate([0, 0, i * (360/N_slots)])
            translate([D_in/2 + (D_out-D_in)/4, 0, 0])
            cube([D_out/4, 5, h_stator+.1], center=true);
        }
    }
}

module magnet() {
    cube([magnet_width, magnet_depth, magnet_height+2], center=true);
}

module rotor() {
    difference() {
        // Main rotor body
        difference() {
            cylinder(h=air_gap, d=D_out-1, center=true);
            cylinder(h=air_gap+1, d=D_in+1, center=true);
        }
        
        // Halbach array magnet cutouts
        for(i = [0:N_magnets-1]) {
            rotate([0, 0, i * (360/N_magnets)])
            translate([D_in/2 + magnet_depth/2, 0, ])
            rotate([0, 0, 45])  // Halbach array orientation
            color("grey") magnet();
        }
    }
}

module rotor_assembly() {
    // Stack stators and rotors alternately
    for(i = [0:4]) {
        if(i < 4) {  // Only 4 rotors needed
            rotor_z = (i * (h_stator + air_gap)) + h_stator/2 + air_gap/2;
            translate([0, 0, rotor_z])
            color("red") rotor();
        }
    }
}

module stator_assembly() {
    // Stack stators and rotors alternately
    for(i = [0:4]) {
        translate([0, 0, i * (h_stator + air_gap)])
        color("blue") stator();
    }
}

module manual_full_assembly() {
    // Stack stators and rotors alternately
    for(i = [0:4]) {
        translate([0, 0, i * (h_stator + air_gap)])
        color("blue") stator();
        
        if(i < 4) {  // Only 4 rotors needed
            rotor_z = (i * (h_stator + air_gap)) + h_stator/2 + air_gap/2;
            translate([0, 0, rotor_z])
            color("red") rotor();
        }
    }
}

module gen_full_assembly() {
    stator_assembly();
    rotor_assembly();
}

// Render assembly
//rotor();
//stator();
//manual_full_assembly();
gen_full_assembly();

// Measurements reference
color("hotpink") {
    translate([-D_out/2, 0, total_height])
    rotate([0, 90, 0])
    cylinder(h=D_out, d=1, $fn=3);
    
    translate([D_out/2 + 15, 0, -h_stator/2])
    cylinder(h=total_height, d=1, $fn=3);
}
