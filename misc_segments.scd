(
w = Window.new.front;
w.view.background_(Color.white);
w.drawFunc = {
	Pen.strokeColor = Color.red;
	~segments.do {|points|
		Pen.line(points[0], points[1]);
	};
	Pen.stroke
};
w.refresh;
)

(
~segments = [
	[0@30, 50@30],
	[0@100, 50@100]
];

~stepNum = ~segments.collect {|pts| pts[0].dist(pts[1]) }.sum;

~loopDur = 2; // secs

~stepDur = ~loopDur / ~stepNum;

// ein paar punkte vom rpi faken
~pointsNow = [ 12@30, 13@100 ];
)

Pdef(\segPlayer, {|seg|
	Pbind(
		\dur, Pfunc { ~stepDur },
		\pts, Plazy { |ev|
			p { |inval|
				var start = seg[0].postln, end = seg[1]; //start = 0@30, end = 50@30;
				while { start.x < end.x } {
					inval = start = start.translate(1@0);
					inval.yield
				};
			}
		},
		\testPoint, Pfunc {|ev| if(~pointsNow.includesEqual(ev.pts)){("trigger at " ++ ev.pts).postln}; 0} //
	)
})

Pn(Plazy{Pseq(~segments.collect{|seg| Pdef(\segPlayer) <> (seg: [seg]) })}).play // wozu muss [seg] ? egal ..

//pointsNow aendern sich
~pointsNow = [ 13@100 ];
~pointsNow = [ 13@100, 20@100 ];


// oder segments aendern sich
~segments = [
	[0@30, 50@30]
];

~segments = [
	[0@30, 50@30],
	[0@100, 50@100]
];


//dreieck
(var a,b,c;
a = (0@50);
b = a.rotate(120.degrad);
c = b.rotate(120.degrad);
a = a.translate(200@200);
b = b.translate(200@200);
c = c.translate(200@200);
/*a = (0@0);
b = a.rotate(120.degrad).translate(50@0);
c = b.rotate(120.degrad).translate(50@0);
/*a = a.translate(200@200);
b = b.translate(200@200);
c = c.translate(200@200);*/*/

~segments = [
	[a, b],
	[b, c],
	[c, a]
];
)

~drawPointOnTop = { |p|
	w.drawFunc = {
		//Pen.translate(200,200);
		Pen.strokeColor = Color.red;
		~segments.do {|points|
			Pen.line(points[0], points[1]);
		};
		Pen.stroke;
		Pen.color = Color.blue;
		Pen.addRect(Rect(p.x, p.y, 5, 5));
		Pen.fillStroke;
	};
	w.refresh;
}

Pdef(\segPlayerDraw, {|seg|
	Pbind(
		\dur, Pfunc { ~stepDur },
		\pts, Plazy { |ev|
			p { |inval|
				var start = seg[0].postln, end = seg[1]; //start = 0@30, end = 50@30;
				var deltaPoint = (end - start) * 0.02;
				while { start.round(0.01) != end.round(0.01) } {
					[start, end].postln;
					inval = start = start.translate(deltaPoint);
					{~drawPointOnTop.(start)}.fork(AppClock);
					inval.yield
				};
			}
		},
		\testPoint, Pfunc {|ev| if(~pointsNow.includesEqual(ev.pts)){("trigger at " ++ ev.pts).postln}; 0} //
	)
})

Pn(Plazy{Pseq(~segments.collect{|seg| Pdef(\segPlayerDraw) <> (seg: [seg]) })}).play
