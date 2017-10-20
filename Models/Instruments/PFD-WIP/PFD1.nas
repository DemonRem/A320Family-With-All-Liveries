# A3XX PFD 1
# Joshua Davidson (it0uchpods)

#########################################
# Copyright (c) it0uchpods Design Group #
#########################################

var PFD_1 = nil;
var PFD_display = nil;
setprop("/instrumentation/pfd/vs-needle", 0);
setprop("/instrumentation/pfd/vs-needle2", 1);
setprop("/it-autoflight/output/ap1", 0);
setprop("/it-autoflight/output/ap2", 0);
setprop("/it-autoflight/output/fd1", 0);
setprop("/it-autoflight/output/fd2", 0);
setprop("/it-autoflight/output/athr", 0);
var alt = 0;
var state1 = getprop("/systems/thrust/state1");
var state2 = getprop("/systems/thrust/state2");
var ap1 = getprop("/it-autoflight/output/ap1");
var ap2 = getprop("/it-autoflight/output/ap2");
var fd1 = getprop("/it-autoflight/output/fd1");
var fd2 = getprop("/it-autoflight/output/fd2");
var athr = getprop("/it-autoflight/output/athr");
var throttle_mode = getprop("/modes/pfd/fma/throttle-mode");
var pitch_mode = getprop("/modes/pfd/fma/pitch-mode");
var pitch_mode_armed = getprop("/modes/pfd/fma/pitch-mode-armed");
var pitch_mode2_armed = getprop("/modes/pfd/fma/pitch-mode2-armed");
var roll_mode = getprop("/modes/pfd/fma/roll-mode");
var roll_mode_armed = getprop("/modes/pfd/fma/roll-mode-armed");
var thr1 = getprop("/controls/engines/engine[0]/throttle-pos");
var thr2 = getprop("/controls/engines/engine[1]/throttle-pos");
var pitch = getprop("/orientation/pitch-deg");
var roll = getprop("/orientation/roll-deg");
var wow1 = getprop("/gear/gear[1]/wow");
var wow2 = getprop("/gear/gear[2]/wow");

var canvas_PFD_base = {
	init: func(canvas_group, file) {
		var font_mapper = func(family, weight) {
			return "LiberationFonts/LiberationSans-Regular.ttf";
		};

		canvas.parsesvg(canvas_group, file, {'font-mapper': font_mapper});

		var svg_keys = me.getKeys();
		foreach(var key; svg_keys) {
			me[key] = canvas_group.getElementById(key);
			var svg_keys = me.getKeys();

			foreach (var key; svg_keys) {
				me[key] = canvas_group.getElementById(key);

				var clip_el = canvas_group.getElementById(key ~ "_clip");
				if (clip_el != nil) {
					clip_el.setVisible(0);
					var tran_rect = clip_el.getTransformedBounds();

					var clip_rect = sprintf("rect(%d,%d, %d,%d)", 
					tran_rect[1], # 0 ys
					tran_rect[2], # 1 xe
					tran_rect[3], # 2 ye
					tran_rect[0]); #3 xs
					#   coordinates are top,right,bottom,left (ys, xe, ye, xs) ref: l621 of simgear/canvas/CanvasElement.cxx
					me[key].set("clip", clip_rect);
					me[key].set("clip-frame", canvas.Element.PARENT);
				}
			}
		}

		me.page = canvas_group;

		return me;
	},
	getKeys: func() {
		return [];
	},
	update: func() {
		if ((getprop("/systems/electrical/bus/ac1") >= 110 or getprop("/systems/electrical/bus/ac2") >= 110) and getprop("/controls/electrical/switches/emer-gen") != 1 and getprop("/options/test-canvas") == 1) {
			PFD_1.page.show();
			PFD_1.update();
		} else {
			PFD_1.page.hide();
		}
	},
};

var canvas_PFD_1 = {
	new: func(canvas_group, file) {
		var m = {parents: [canvas_PFD_1, canvas_PFD_base]};
		m.init(canvas_group, file);

		return m;
	},
	getKeys: func() {
		return ["FMA_man","FMA_manmode","FMA_flxtemp","FMA_thrust","FMA_lvrclb","FMA_pitch","FMA_pitcharm","FMA_pitcharm2","FMA_roll","FMA_rollarm","FMA_combined","FMA_catmode","FMA_cattype","FMA_nodh","FMA_dh","FMA_dhn","FMA_ap","FMA_fd","FMA_athr",
		"FMA_man_box","FMA_flx_box","FMA_thrust_box","FMA_pitch_box","FMA_pitcharm_box","FMA_roll_box","FMA_rollarm_box","FMA_combined_box","FMA_catmode_box","FMA_cattype_box","FMA_cat_box","FMA_dh_box","FMA_ap_box","FMA_fd_box","FMA_athr_box","FMA_Middle1",
		"FMA_Middle2","AI_center","AI_bank","AI_slipskid","FD_roll","FD_pitch","ALT_digits","ALT_tens","VS_pointer_g","VS_pointer","VS_pos_mask","VS_neg_mask","QNH_setting","LOC_pointer","LOC_scale","GS_scale","GS_pointer"];
	},
	update: func() {
		state1 = getprop("/systems/thrust/state1");
		state2 = getprop("/systems/thrust/state2");
		ap1 = getprop("/it-autoflight/output/ap1");
		ap2 = getprop("/it-autoflight/output/ap2");
		fd1 = getprop("/it-autoflight/output/fd1");
		fd2 = getprop("/it-autoflight/output/fd2");
		athr = getprop("/it-autoflight/output/athr");
		throttle_mode = getprop("/modes/pfd/fma/throttle-mode");
		pitch_mode = getprop("/modes/pfd/fma/pitch-mode");
		pitch_mode_armed = getprop("/modes/pfd/fma/pitch-mode-armed");
		pitch_mode2_armed = getprop("/modes/pfd/fma/pitch-mode2-armed");
		roll_mode = getprop("/modes/pfd/fma/roll-mode");
		roll_mode_armed = getprop("/modes/pfd/fma/roll-mode-armed");
		thr1 = getprop("/controls/engines/engine[0]/throttle-pos");
		thr2 = getprop("/controls/engines/engine[1]/throttle-pos");
		pitch = getprop("/orientation/pitch-deg");
		roll = getprop("/orientation/roll-deg");
		wow1 = getprop("/gear/gear[1]/wow");
		wow2 = getprop("/gear/gear[2]/wow");
		
		# FMA MAN TOGA MCT FLX THR
		if (athr == 1 and (state1 == "TOGA" or state1 == "MCT" or state1 == "MAN THR" or state2 == "TOGA" or state2 == "MCT" or state2 == "MAN THR")) {
			me["FMA_man"].show();
			me["FMA_manmode"].show();
			if (state1 == "TOGA" or state2 == "TOGA") {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].setText("TOGA");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((state1 == "MAN THR" and thr1 >= 0.83) or (state2 == "MAN THR" and thr2 >= 0.83)) {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].setText("THR");
				me["FMA_man_box"].setColor(0.7333,0.3803,0);
			} else if ((state1 == "MCT" or state2 == "MCT") and getprop("/controls/engines/thrust-limit") != "FLX") {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].setText("MCT");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((state1 == "MCT" or state2 == "MCT") and getprop("/controls/engines/thrust-limit") == "FLX") {
				me["FMA_flxtemp"].setText(sprintf("%s", "+" ~ getprop("/FMGC/internal/flex")));
				me["FMA_man_box"].hide();
				me["FMA_flx_box"].show();
				me["FMA_flxtemp"].show();
				me["FMA_manmode"].setText("FLX            ");
				me["FMA_man_box"].setColor(0.8078,0.8039,0.8078);
			} else if ((state1 == "MAN THR" and thr1 < 0.83) or (state2 == "MAN THR" and thr2 < 0.83)) {
				me["FMA_flx_box"].hide();
				me["FMA_flxtemp"].hide();
				me["FMA_man_box"].show();
				me["FMA_manmode"].setText("THR");
				me["FMA_man_box"].setColor(0.7333,0.3803,0);
			}
		} else {
			me["FMA_man"].hide();
			me["FMA_manmode"].hide();
			me["FMA_man_box"].hide();
			me["FMA_flx_box"].hide();
			me["FMA_flxtemp"].hide();
		}
		
		if (athr == 1 and getprop("/systems/thrust/lvrclb") == 1) {
			me["FMA_lvrclb"].show();
		} else {
			me["FMA_lvrclb"].hide();
		}
	
		# FMA A/THR
		if (athr == 1 and ((state1 == "MAN" or state1 == "CL") and (state2 == "MAN" or state2 == "CL"))) {
			me["FMA_thrust"].show();
			if (getprop("/modes/pfd/fma/throttle-mode-box") == 1 and throttle_mode != " ") {
				me["FMA_thrust_box"].show();
			} else {
				me["FMA_thrust_box"].hide();
			}
		} else {
			me["FMA_thrust"].hide();
			me["FMA_thrust_box"].hide();
		}
		
		me["FMA_thrust"].setText(sprintf("%s", throttle_mode));
		
		# FMA Pitch Roll Common
		me["FMA_combined"].setText(sprintf("%s", pitch_mode));
		
		if (pitch_mode == "LAND" or pitch_mode == "FLARE" or pitch_mode == "ROLL OUT") {
			me["FMA_pitch"].hide();
			me["FMA_roll"].hide();
			me["FMA_pitch_box"].hide();
			me["FMA_roll_box"].hide();
			me["FMA_pitcharm_box"].hide();
			me["FMA_rollarm_box"].hide();
			me["FMA_Middle1"].hide();
			me["FMA_Middle2"].hide();
			me["FMA_combined"].show();
			if (getprop("/modes/pfd/fma/pitch-mode-box") == 1) {
				me["FMA_combined_box"].show();
			} else {
				me["FMA_combined_box"].hide();
			}
		} else {
			me["FMA_combined"].hide();
			me["FMA_combined_box"].hide();
			me["FMA_Middle1"].show();
			me["FMA_Middle2"].show();
			if (ap1 or ap2 or fd1 or fd2) {
				me["FMA_pitch"].show();
				me["FMA_roll"].show();
			} else {
				me["FMA_pitch"].hide();
				me["FMA_roll"].hide();
			}
			if (getprop("/modes/pfd/fma/pitch-mode-box") == 1 and pitch_mode != " " and (ap1 or ap2 or fd1 or fd2)) {
				me["FMA_pitch_box"].show();
			} else {
				me["FMA_pitch_box"].hide();
			}
			if (pitch_mode_armed == " " and pitch_mode2_armed == " ") {
				me["FMA_pitcharm_box"].hide();
			} else {
				if ((getprop("/modes/pfd/fma/pitch-mode-armed-box") == 1 or getprop("/modes/pfd/fma/pitch-mode2-armed-box") == 1) and (ap1 or ap2 or fd1 or fd2)) {
					me["FMA_pitcharm_box"].show();
				} else {
					me["FMA_pitcharm_box"].hide();
				}
			}
			if (getprop("/modes/pfd/fma/roll-mode-box") == 1 and roll_mode != " " and (ap1 or ap2 or fd1 or fd2)) {
				me["FMA_roll_box"].show();
			} else {
				me["FMA_roll_box"].hide();
			}
			if (getprop("/modes/pfd/fma/roll-mode-armed-box") == 1 and roll_mode_armed != " " and (ap1 or ap2 or fd1 or fd2)) {
				me["FMA_rollarm_box"].show();
			} else {
				me["FMA_rollarm_box"].hide();
			}
		}
		
		if (ap1 or ap2 or fd1 or fd2) {
			me["FMA_pitcharm"].show();
			me["FMA_pitcharm2"].show();
			me["FMA_rollarm"].show();
		} else {
			me["FMA_pitcharm"].hide();
			me["FMA_pitcharm2"].hide();
			me["FMA_rollarm"].hide();
		}
		
		# FMA Pitch
		me["FMA_pitch"].setText(sprintf("%s", pitch_mode));
		me["FMA_pitcharm"].setText(sprintf("%s", pitch_mode_armed));
		me["FMA_pitcharm2"].setText(sprintf("%s", pitch_mode2_armed));
		
		# FMA Roll
		me["FMA_roll"].setText(sprintf("%s", roll_mode));
		me["FMA_rollarm"].setText(sprintf("%s", roll_mode_armed));
		
		# FMA CAT DH
		me["FMA_catmode"].hide();
		me["FMA_cattype"].hide();
		me["FMA_catmode_box"].hide();
		me["FMA_cattype_box"].hide();
		me["FMA_cat_box"].hide();
		me["FMA_nodh"].hide();
		me["FMA_dh_box"].hide();
		
		# FMA AP FD ATHR
		me["FMA_ap"].setText(sprintf("%s", getprop("/modes/pfd/fma/ap-mode")));
		me["FMA_fd"].setText(sprintf("%s", getprop("/modes/pfd/fma/fd-mode")));
		me["FMA_athr"].setText(sprintf("%s", getprop("/modes/pfd/fma/at-mode")));
		
		if ((state1 == "MAN" or state1 == "CL") and (state2 == "MAN" or state2 == "CL")) {
			me["FMA_athr"].setColor(0.8078,0.8039,0.8078);
		} else {
			me["FMA_athr"].setColor(0.1372,0.5372,0.5843);
		}
		
		if (getprop("/modes/pfd/fma/ap-mode-box") == 1) {
			me["FMA_ap_box"].show();
		} else {
			me["FMA_ap_box"].hide();
		}
		
		if (getprop("/modes/pfd/fma/fd-mode-box") == 1) {
			me["FMA_fd_box"].show();
		} else {
			me["FMA_fd_box"].hide();
		}
		
		if (getprop("/modes/pfd/fma/athr-mode-box") == 1 and getprop("/modes/pfd/fma/at-mode") != " ") {
			me["FMA_athr_box"].show();
		} else {
			me["FMA_athr_box"].hide();
		}
		
		# Attitude Indicator
		me["AI_slipskid"].setTranslation(getprop("/instrumentation/slip-skid-ball/indicated-slip-skid") * -20, 0);
		me["AI_bank"].setRotation(-roll * D2R);
		
		if (fd1 == 1 and !wow1 and !wow2 and getprop("/it-autoflight/custom/trk-fpa") == 0 and pitch < 25 and pitch > -13 and roll < 45 and roll > -45) {
			me["FD_roll"].show();
			me["FD_pitch"].show();
		} else {
			me["FD_roll"].hide();
			me["FD_pitch"].hide();
		}
		
		if (getprop("/it-autoflight/fd/roll-bar") != nil) {
			me["FD_roll"].setTranslation((getprop("/it-autoflight/fd/roll-bar"))*2.0, 0);
		}
		if (getprop("/it-autoflight/fd/pitch-bar") != nil) {
			me["FD_pitch"].setTranslation(0, -(getprop("/it-autoflight/fd/pitch-bar"))*3.8);
		}
		
		# Altitude
		me["ALT_digits"].setText(sprintf("%s", getprop("/instrumentation/altimeter/indicated-altitude-ft-pfd")));
#		me["ALT_tens"].setTranslation(0,getprop("/instrumentation/altimeter/indicated-altitude-ft1") * 1.38); # Needs alot of work
		
		# QNH
		if (getprop("/modes/altimeter/std") == 1) {
			me["QNH_setting"].setText(sprintf("%s", "STD"));
		} else if (getprop("/modes/altimeter/inhg") == 0) {
			me["QNH_setting"].setText(sprintf("%4.0f", getprop("/instrumentation/altimeter/setting-hpa")));
		} else if (getprop("/modes/altimeter/inhg") == 1) {
			me["QNH_setting"].setText(sprintf("%2.2f", getprop("/instrumentation/altimeter/setting-inhg")));
		}
		
		# Vertical Speed
		me["VS_pointer"].setScale(getprop("/instrumentation/pfd/vs-needle2"), 1);
		me["VS_pointer_g"].setRotation(getprop("/instrumentation/pfd/vs-needle") * D2R);
		
		if (getprop("/it-autoflight/internal/vert-speed-fpm-filtered") > 0) {
			me["VS_pos_mask"].hide();
			me["VS_neg_mask"].show();
		} else {
			me["VS_neg_mask"].hide();
			me["VS_pos_mask"].show();
		}
		
		# ILS
		if (getprop("/modes/pfd/ILS1") == 1) {
			me["LOC_pointer"].show();
			me["LOC_scale"].show();
			me["GS_pointer"].show();
			me["GS_scale"].show();
		} else {
			me["LOC_pointer"].hide();
			me["LOC_scale"].hide();
			me["GS_pointer"].hide();
			me["GS_scale"].hide();
		}
	},
};

setlistener("sim/signals/fdm-initialized", func {
	PFD_display = canvas.new({
		"name": "PFD",
		"size": [1024, 1024],
		"view": [1024, 1024],
		"mipmapping": 1
	});
	PFD_display.addPlacement({"node": "pfd1.screen"});
	var group_pfd1 = PFD_display.createGroup();

	PFD_1 = canvas_PFD_1.new(group_pfd1, "Aircraft/IDG-A32X/Models/Instruments/PFD-WIP/res/pfd.svg");
	
	PFD_update.start();
});

var PFD_update = maketimer(0.05, func {
	canvas_PFD_base.update();
});

var showPFD1 = func {
	var dlg = canvas.Window.new([512, 512], "dialog").set("resize", 1);
	dlg.setCanvas(PFD_display);
}
