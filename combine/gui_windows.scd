~gui = ();
~gui.resolution = [ 270, 392 ];
~gui.offset = Point( 196, 135 ); //wird auch fuer rechts benutzt...
~gui.fps = 24;
~gui.res2 = ~gui.resolution * 2;

~gui.window = Window("circles", Rect(0, 0, ~gui.resolution[1] * 6 + 8, ~gui.resolution[0] * 4 + 6));
~gui.window.view.background = Color.black;
~gui.window.front;

~drumCircle.view = UserView(~gui.window, Rect(2, 2, ~gui.res2[1], ~gui.res2[0])).background_(Color.white);
~clickCircle.view = UserView(~gui.window, Rect(2, ~gui.res2[0] + 4, ~gui.res2[1], ~gui.res2[0])).background_(Color.white);
~chordsBassCircle.view = UserView(~gui.window, Rect(~gui.res2[1] + 4, 2, ~gui.res2[1], ~gui.res2[0])).background_(Color.white);
~arpCircle.view = UserView(~gui.window, Rect(~gui.res2[1] + 4, ~gui.res2[0] + 4, ~gui.res2[1], ~gui.res2[0])).background_(Color.white);

~cues = (
	list: [
		"Clicks Intro; Resonance voll -> Staccato Akkorde (instr 0)",
		"Clicks ausdünnen -> Kick & Bass (simpel, impulsig)\n -> Clicks raus, Akkorde weniger und zu Legato",
		"Volle Verzerrung BD und Bass -> BD raus, Bass raus",
		"Filter auf den Chords -> Arpeggiator (einzeln)",
		"Plucks sind kurz -> Kick & Bass rein",
		"Kick dunkel (srr) -> Kick raus, Bass raus",
		"Arp solo, simpel & durchgängig (Philipp). 4/4 Kick rein",
		"Vibrato voll -> kick raus; Glide hoch -> Arp Kreise raus bis auf äußeren",
		"Arp viele noteOns, Klicks kommen rein (10er Quant)",
		"Phaser, gliss nach oben -> Drums dazu (hh erst), Chords dazu (instr 0)",
		"letzter Arp raus, Clicks ausdünnen; Quant auf 8; Clicks raus, Akkorde pulsig",
		"bass dazu; Chords werden langsamer; bis Auf chords & kick alle wieder raus (auch bass raus!), chords auf instrument 1 -> auf lange release von chords warten!",
		"chords wieder schneller für philipp; und wieder langsamer",
		"chords slow att -> vereinzelt kicks; kicks hören auf, chords hören auf"
	],
	view: StaticText(~gui.window, Rect(~gui.res2[1] * 2 + 6, ~gui.res2[0] + 4, ~gui.res2[1], ~gui.res2[0])).background_(Color.white).align_(\topLeft).font_(Font("Hack", 24)),
	cnt: 0,
	inc: { |self| self.cnt = self.cnt + 1 },
	dec: { |self| self.cnt = (self.cnt - 1).clip(0,100)},
	setCue: {|self|
		{
			self.view.string = (
				"--CUES--\n\nNOW: " ++
				self.list[self.cnt] ++
				"\n\n\n\nNEXT: " ++ self.list[self.cnt + 1]);
		}.defer
	},
	nextCue: {|self| self.inc; self.setCue},
	lastCue: {|self| self.dec; self.setCue}
);
~cues.view.parent.keyDownAction = {|view, char, mod, unicode|
	if(unicode == 32){~cues.nextCue};
	if(unicode == 98){~cues.lastCue};
};
~cues.setCue;
//~cues.view.setFont(Font("Hack", 24),0);

~gui.refreshPoints = SkipJack(
	updateFunc: {~gui.window.refresh},
	dt: (1 / ~gui.fps)
);

[~drumCircle, ~clickCircle, ~chordsBassCircle, ~arpCircle].do {|instrumentCircle|
	instrumentCircle.view.drawFunc = {
		Pen.scale(2,2);
		Pen.stringAtPoint(instrumentCircle.guiText, 4@5, Font("Hack", 16), Color.black);
		Pen.use {
			var hits = List.new;
			instrumentCircle.circs.do { |ci|
				if(ci.sharedValues.onOff.asBoolean){
					Pen.color = Color.black();
					Pen.addOval(Rect(
						~gui.offset.x - ci.radius,
						~gui.offset.y - ci.radius,
						ci.circumference,
						ci.circumference));
					Pen.stroke;
					if(ci.muteNow.not){
						Pen.color = ci.guiColor;
						if(ci.guiHit > 0){
							hits.add([
								Rect(*(
									Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~gui.offset - (ci.guiHit * 0.5)).asArray  ++ [ci.guiHit, ci.guiHit]
								)),
								ci.guiColor
							]);
							ci.guiHit = ci.guiHit - 8;
						}{
							Pen.addOval(
								Rect(*(
									Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~gui.offset - 3).asArray  ++ [6, 6]
								))
							);
						};
						Pen.fill;
					}{
						Pen.color = Color.black;
						Pen.addRect(
							Rect(*(
								Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~gui.offset - 2).asArray  ++ [2, 8]
							))
						);
						Pen.fill;
					};
				};
			};
			hits.do {|arr| Pen.color = arr[1]; Pen.addOval(arr[0]); Pen.fill};

			if(instrumentCircle.sharedValues.freezeMe.asBoolean){
				Pen.color = Color.black();
			}{
				Pen.color = Color.green();
			};
			instrumentCircle.points.do {|p|
				Pen.addRect(
					Rect(*((p - 3) ++ [6, 6]))
				);
			};
			Pen.fill;
		};
	};
};