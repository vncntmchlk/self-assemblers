(
// modified by an example of Stefan Wittwer
w = Window("aa",Rect(100,100,382,316)).front;
w.view.background_(Color.white);
w.drawFunc = {

	Pen.use { // draw something complex...
		Pen.moveTo(100@100);
		Pen.lineTo(150@150);
	};
	Pen.stroke;
};
w.refresh
)

thisProcess.openUDPPort(9000);

~contours = List.new;
~contours[0].size
OSCdef(\contour, {|msg|
	~contours.add(msg[1..].clump(2));
}, '/contour');

OSCdef(\finished, {|msg|
	if(~contours.size > 0){
		"start drawing % contours".format(~contours.size).postln;
		{
			w.drawFunc = {
				Pen.use {
					~contours.do { |c|
						Pen.moveTo(c[0].asPoint);
						c[1..].do {|p|
							Pen.lineTo(p.asPoint);
						};
						Pen.stroke;
					};
				};
				~contours.clear;
			};
			w.refresh;
		}.fork(AppClock);
	};
}, '/finished');


~contours.collect{|c| c.size}
OSCdef(\contour, {|msg|
	~contours.add(msg[1..].clump(2));
}, '/contour');

OSCdef(\finished, {|msg|
	if(~contours.size > 0){
		var contours = ~contours.copy;
		~contours.clear;
		"start drawing % contours".format(contours.size).postln;
		{
			w.drawFunc = {
				Pen.use {
					contours.do { |c|
						Pen.moveTo(c[0].asPoint);
						c[1..].do {|p|
							Pen.lineTo(p.asPoint);
						};
						Pen.stroke;
					};
				};
			};
			w.refresh;
		}.fork(AppClock);
	};
}, '/finished');



// clear by hand
(
w = Window("draw on me", Rect(128, 64, 382,316));
​
v = UserView(w,w.view.bounds)
.clearOnRefresh_(false)
.background_(Color.white);

~contours = List.new;
OSCdef(\contour, {|msg|
	~contours.add(msg[1..].clump(2).collect{|c|c.asPoint});
}, '/contour');

OSCdef(\finished, {|msg|
	if(~contours.size > 0){
		{
			var contours = ~contours.copy;
			var pointsWithTime = ();
			var timeStep = 0.0;

			contours.do {|cont|
				var quant = 4 / cont.size; // 2fps
				var inc = 0;
				cont.doAdjacentPairs {|a, b|
					var index = (inc.round(0.05) * 100).asInteger;
					pointsWithTime[index] ?? { pointsWithTime[index] = List.new };
					pointsWithTime[index].add([a, b]);
					// pointsWithTime.add([inc.round(0.05), a, b]); // timestamp, point a, point b
					inc = inc + quant;
				}
			};
			// pointsWithTime[0.1].postln;
			~contours.clear;
			"start drawing % contours".format(contours.size).postln;
			// von 0 bis 0.5 in 0.05 schritten
			v.drawFunc_{
				Pen.use {
					Pen.width = 1;
					Color.black.set;
					if(pointsWithTime[timeStep].notNil){
						pointsWithTime[timeStep].do {|pts|
							​Pen.line(pts[0],pts[1]);
						};
						Pen.stroke;
					}
				};
			};
			(0, 5 .. 200).do {|ts|
				v.refresh;
				pointsWithTime[ts];
				timeStep = ts;
				0.045.wait;
			};
			v.clearDrawing;
			// v.clearDrawing; // fuer spaeter wichtig wenn es nicht direkt weg soll

		}.fork(AppClock);
	};
}, '/finished');
​
w.front;
)

~aa[0.1].printAll

// Idee: die konturen werden auf eine zeitliche achse gemappt (entsprechend der refresh rate und der anzahl der punkte der kontur)
// anschliessend werden in der draw funktion immer die zeitlich relevanten nachbar punkte gemalt
~contoursWithTime = ~contours.collect {|cont|
	var quant = 0.5 / cont.size; // 2fps
	var inc = 0;
	var pointsWithTime = ();
	cont.doAdjacentPairs {|a, b|
		pointsWithTime[inc.round(0.05)] ?? { pointsWithTime[inc.round(0.05)] = List.new };
		pointsWithTime[inc.round(0.05)].add([a, b]);
		// pointsWithTime.add([inc.round(0.05), a, b]); // timestamp, point a, point b
		inc = inc + quant;
	};
	pointsWithTime
}

~contoursWithTime[0][0.0]


~contoursWithTime[0].flop
