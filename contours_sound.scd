thisProcess.openUDPPort(9000);

n = NetAddr("192.168.1.101", 8000);
n.sendMsg("/freq1", 127.0)
// clear by hand
(
~fps = 1/2;
~quantSize = 0.05;
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
		var contours = ~contours.copy;
		var pointsWithTime = Order.new(40);
		contours.do {|cont, contIx|
			var quant = ~fps / cont.size; // 2fps
			var inc = 0;
			cont.doAdjacentPairs {|a, b|
				var index = (inc.round(~quantSize) * 100).asInteger;
				pointsWithTime[index] ?? { pointsWithTime[index] = List.new };
				pointsWithTime[index].add([a, b, contIx]);
				inc = inc + quant;
			}
		};
		{
			var timeStep = 0.0;
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
			(0, (~quantSize * 100) .. (~fps * 100)).do {|ts|
				v.refresh;
				timeStep = ts;
				~quantSize.wait;
			};
			v.clearDrawing;
			// v.clearDrawing; // fuer spaeter wichtig wenn es nicht direkt weg soll

		}.fork(AppClock);
		// audio thread
		{
			var thetaLists = List.new!40;
			(0, (~quantSize * 100) .. (~fps * 100)).do {|ts|
				if(pointsWithTime[ts].notNil){
					pointsWithTime[ts].do {|pts, ix|
						//if(pts[2] == 0){
						var theta = (pts[1] - pts[0]).theta.raddeg;
						thetaLists[pts[2]].addFirst(theta);
						if(thetaLists[pts[2]].size > 14){
							var thetaAvg = (thetaLists[pts[2]].sum / 15).linlin(-180,180,0,100);
							n.sendMsg("/freq" ++ (pts[2] + 1),thetaAvg);
							[thetaAvg, pts[2]].postln;
							thetaLists[pts[2]].pop
						};
						//}
					}
				};
				~quantSize.wait;
			};
		}.fork
	};
}, '/finished');
​
w.front;
)



//gleitenden mittelwert
