# A3XX Electronic Centralised Aircraft Monitoring System
# Jonathan Redpath (legoboyvdlp)

##############################################
# Copyright (c) Joshua Davidson (it0uchpods) #
##############################################

# Colors:
# 1 - Red, 2 - Amber, 3 - Cyan 4 - Green 5 - White

# Priority: 1 - LEVEL 3    2 - LEVEL 2    3 - LEVEL 1     4 - LEVEL 0     5 - MEMO
# LEVEL 3 has priority over all other warnings
# LEVEL 2 has priority over 1 and 0
# LEVEL 1 has priority over 0

# LEVEL 3 Messages Priority:
# Red visual warning, repetitive chime or sound
# 1 Stall
# 2 Over speed
# 3 Engine dual failure
# 4 Engine fire
# 5 APU fire
# 6 Takeoff configuration
# 7 Sidestick fault
# 8 Excessive cabin altitude
# 9 Engine oil lo pressure
# 10 L + R Elevator fault
# 11 Landing gear
# 12 Autopilot disconnection
# 13 Auto land
# 14 Smoke
# 15 Emergency configuration
# 16 Dual hydraulic failure

# LEVEL 2 Messages:
# Amber warning, single chime

# LEVEL 1 Messages:
# Amber warning, no chime

# LEVEL 0 Messages: 
# No visual warning or chime: ECAM blue, green, or white message

# TYPES: Independent, Primary and Secondary, Status, and MEMO

# Operation: FWC receives electrical boolean or numeric signals, from the systems, and outputs a message, audible warning, or visual alert

# Electrical Connection: FWC1 is controlled by AC ESS, FWC2 by AC BUS 2

# Sounds: reduce volume by 6DB is engines are off

# ARINC 429: 100kb/s (high speed)

# PHASE: /FMGC/status/phase

# DISPLAY: 1 - EWD 2 - MEMO 3 - STATUS
var ewd = props.globals.initNode("/instrumentation/ewd");
var ewd_msg_three	= ewd.initNode("msg/priority_3"," ","STRING");
var ewd_msg_two		= ewd.initNode("msg/priority_2"," ","STRING");
var ewd_msg_one		= ewd.initNode("msg/priority_1"," ","STRING");
var ewd_msg_zero	= ewd.initNode("msg/priority_0"," ","STRING");
var ewd_msg_memo	= ewd.initNode("msg/memo"," ","STRING");
var msgs_priority_3 = std.Vector.new();
var msgs_priority_2 = std.Vector.new();
var msgs_priority_1 = std.Vector.new();
var msgs_priority_0 = std.Vector.new();
var msgs_memo = std.Vector.new();
var right_memo = std.Vector.new();
var active_messages = std.Vector.new();
var display_messages = std.Vector.new();
var right_display_messages = std.Vector.new();
var num_lines = 6;
var msg = nil;
var spacer = nil;
var line = nil;

# messages logic and added to arrays

var messages_priority_3 = func {
	if (getprop("/controls/flight/flap-pos") > 2 and getprop("/position/gear-agl-ft") < 750 and getprop("/gear/gear[1]/position-norm") != 1 and getprop("/FMGC/status/phase") == 5) {
		msgs_priority_3.append("L/G GEAR NOT DOWN");
		active_messages.append("L/G GEAR NOT DOWN");
	} else if (display_messages.contains("L/G GEAR NOT DOWN")) {
		display_messages.remove("L/G GEAR NOT DOWN");
	}
}
var messages_priority_2 = func {}
var messages_priority_1 = func {}
var messages_priority_0 = func {}
var messages_memo = func {}
var messages_right_memo = func {
	if (getprop("controls/flight/speedbrake-arm") == 1) {
		right_memo.append("GND SPLRS ARMED");
	} else {
		while (right_display_messages.contains("GND SPLRS ARMED")) {
			right_display_messages.remove("GND SPLRS ARMED");
		}
	}
	if (getprop("/controls/gear/brake-parking") == 1) {
		right_memo.append("PARK BRK");
	} else {
		while (right_display_messages.contains("PARK BRK")) {
			right_display_messages.remove("PARK BRK");
		}
	}
}

# Finally the controller

var ECAM_controller = {
	loop: func() {
		# cleans up arrays
		msgs_priority_3.clear();
		msgs_priority_2.clear();
		msgs_priority_1.clear();
		msgs_priority_0.clear();
		msgs_memo.clear();
		active_messages.clear();
		right_memo.clear();
		
		# check active messages
		# config_warnings();
		messages_priority_3();
		messages_priority_2();
		messages_priority_1();
		messages_priority_0();
		messages_memo();
		messages_right_memo();
		
		# write to ECAM
		
		forindex ( var i; active_messages.vector ) {
			line = 1;
			while (getprop("/ECAM/msg/line" ~ line) != "") {
				line = line + 1; # go to next line until empty line
			} 
		    if (getprop("/ECAM/msg/line" ~ line) == ""){ # at empty line
				if (display_messages.size() > 0) { # is the display empty or is this first message?
					msg = active_messages.vector[i]; # get the message that we will be setting
					if (!display_messages.contains(msg)) {  # check: does it exist yet on the display?
						display_messages.append(active_messages.vector[i]); # if not, send it to display
						active_messages.remove(active_messages.vector[i]); 
						setprop("/ECAM/msg/line" ~ (line), display_messages.vector[i]); # and write it
					}
				} else {
					display_messages.append(active_messages.vector[i]);
					active_messages.remove(active_messages.vector[i]);
					setprop("/ECAM/msg/line" ~ (line), display_messages.vector[i]);
				}
			}
		}
		
		forindex ( var x; right_memo.vector ) {
			line = 1;
			while (getprop("/ECAM/rightmsg/line" ~ line) != "") {
				line = line + 1; # go to next line until empty line
			} 
		    if (getprop("/ECAM/rightmsg/line" ~ line) == ""){ # at empty line
				if (right_display_messages.size() > 0) { # is the display empty or is this first message?
					msg = right_memo.vector[x]; # get the message that we will be setting
					if (!right_display_messages.contains(msg)) {  # check: does it exist yet on the display?
						right_display_messages.append(right_memo.vector[x]); # if not, send it to display
						right_memo.remove(right_memo.vector[x]); 
						setprop("/ECAM/rightmsg/line" ~ (line), right_display_messages.vector[x]); # and write it
					}
				} else {
					right_display_messages.append(right_memo.vector[x]);
					right_memo.remove(right_memo.vector[x]);
					setprop("/ECAM/rightmsg/line" ~ (line), right_display_messages.vector[x]);
				}
			}
		}
		
		if (display_messages.size() == 0) {
			setprop("/ECAM/msg/line1", "");
			setprop("/ECAM/msg/line2", "");
		}
		
		if (right_display_messages.size() == 0) {
			setprop("/ECAM/rightmsg/line1", "");
			setprop("/ECAM/rightmsg/line2", "");
		}
	},
};
