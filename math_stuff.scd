thisProcess.openUDPPort(9000)


OSCdef(\resolution, { |msg| ~resolution = msg[1..].postln},'/resolution').oneShot

(
w = Window("my name is... panel", Rect(128, 64, ~resolution[1], ~resolution[0]));
w.front;
w.view.background = Color.white;
~offset = Point((w.bounds.width / 2),  (w.bounds.height / 2)) * -1
)
SynthDef(\beep, { Out.ar(0, SinOsc.ar(\freq.kr(440)) * 0.3 * Env.perc(0.01,0.2).ar(doneAction: 2) ! 2) }).add
Synth(\beep)
(
​OSCdef(\points,{|msg|
	var points = msg[1..].clump(2);
	var angles;
	if(points.notEmpty){
		angles = points.collect {|p|
			[Point(p[0], p[1]).translate(~offset).theta.raddeg + 180, Point(p[0], p[1]).dist(~offset * -1).round]
		};
		// angles.postln;
	};
	{
		w.drawFunc = {
			Pen.use {
				Pen.addOval(Rect(~offset.x * -1 - 70,~offset.y * -1 -70,140,140)); // muss doppelt so gross sein wie der radius (durchmesser = 2 * radius)
				Pen.addOval(Rect(~offset.x * -1 - 90,~offset.y * -1 -90,180,180));
				Pen.addOval(Rect(~offset.x * -1 - 110,~offset.y * -1 -110,220,220));
				Pen.perform([\stroke]);

				Pen.color = Color.green();
				points.do {|p|
					Pen.addRect(
						Rect(*(p ++ [10, 10]))
					);
				};
				Pen.perform([\fill]);
			};
		};
		w.refresh;
	}.fork(AppClock);
	~angles = angles;
	~angles70 = ~angles.select{|ang| ang[1] == 70};
	~angles90 = ~angles.select{|ang| ang[1] == 90};
	~angles110 = ~angles.select{|ang| ang[1] == 110};

}, '/points');

{
	inf.do {|i|
		if(~angles70.notNil){
			~angles70.do{|ang|
				if(ang[0].asInteger == (i%360)){
					Synth(\beep, [\freq, 520])
				}
			}
		};
		// if((i%360) == 0){
		//	Synth(\beep, [\freq, 666])
	// };
		(0.5/360).wait;
	}
}.fork;

{
	inf.do {|i|
		if(~angles90.notNil){
			~angles90.do{|ang|
				if(ang[0].asInteger == (i%360)){
					Synth(\beep, [\freq, 440])
				}
			}
		};
		(1/360).wait;
	}
}.fork;

{
	inf.do {|i|
		if(~angles110.notNil){
			~angles110.do{|ang|
				if(ang[0].asInteger == (i%360)){
					Synth(\beep, [\freq, 410])
				}
			}
		};
		(2/360).wait;
	}
}.fork;

/*{
	inf.do {|i|
		if(~angles.notNil){
			~angles.do{|ang|
				if(ang[0].asInteger == (i%360)){
					Synth(\beep, [\freq, ang.lincurve(0,360,440,880)])
				}
			}
		};
		// if((i%360) == 0){
		//	Synth(\beep, [\freq, 666])
	// };
		(0.5/360).wait;
	}
}.fork*/
)

(
~inc = 0;
~move_circle = {
	var x, y;
	~inc = ~inc + 0.01;
	// (~inc % 1).asin.raddeg.postln;
	x = (~inc.sin * 400);
	y = (~inc.cos * 400);
	[((2 * pi) - (x / y).atan).raddeg,
		450 - (Point(x, y).theta.raddeg + 360)].postln;
	([x + 400, 400 - y]);
}
)

~move_circle.value

60.degrad.sin

0.86602540378444.asin.raddeg

Point(0.5, -1).theta.raddeg

Point(0.5, -1).angle