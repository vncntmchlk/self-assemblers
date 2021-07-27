// network connection
thisProcess.openUDPPort(9000); // receive port from rpi
~rpiAddr = NetAddr("10.42.0.208", 9001); // send addr to rpi
~benniAddr = NetAddr("192.168.1.100", 8000); // send addr to benni

~offsetLeft = Point( 98, 135 ); //wird auch fuer rechts benutzt...
OSCdef(\resolution, { |msg|
	~resolution = msg[[1,2]].postln;
	~offsetLeft = Point(*msg[[3,4]]).postln;
	~offsetRight = Point(*msg[[5,6]]).postln;
},'/resolution').oneShot;

~linkClock = LinkClock.new(1).permanent_(true);

{
	var amps = (4: 127, 8: 70, 16: 45);
	~quantAmps = Env([
		amps[4],amps[16],amps[8],amps[16],
		amps[4],amps[16],amps[8],amps[16],
		amps[4],amps[16],amps[8],amps[16],
		amps[4],amps[16],amps[8],amps[16],amps[4]
	],[1/4],[-4,4]);
}.value;

~makeAngle = { |radius, circleNum, instrumentNum, waitDur, quantVal = 0.25, guiColor|
	(
		radius: radius,
		circumference: radius * 2,
		circleNum: circleNum,
		quantVal: quantVal,
		instrumentNum: instrumentNum,
		waitDur: waitDur,
		testAngle: 0,
		guiHit: 0,
		guiColor: guiColor,
		triggerNote: { |self, vel|
			// ~benniAddr.sendMsg("/circleNumber", self.circleNum, self.instrumentNum, vel)
		},
		getIntersections: { |self, angles| self.intersections = angles.select{|ang| ang[1] == self.radius} },
		start: { |self|
			Task({
				inf.do {|i|
					self.testAngle = i % 360;
					if(self.intersections.notNil){
						self.intersections.do { |ang|
							if(ang[0].asInteger == self.testAngle){
								self.guiHit = 16; // koennte anhand der velocity skalieren
								thisThread.clock.sched(self.quantVal - thisThread.beats.mod(self.quantVal),{
									var velocityOfCircle = (i % 90).fold2(45).linlin(0,44,10,127);
									var velocityOfClock = ~quantAmps[thisThread.beats.mod(4)];
									[self.circleNum, self.instrumentNum, velocityOfClock].postln;
									self.triggerNote(velocityOfClock)
								})
							}
						}
					};
					self.waitDur.wait;
				}
			}, ~linkClock).start(quant: [4,0,-0.025]);
		}
	);
};

~circ0 = ~makeAngle.(radius: 40, circleNum: 0, instrumentNum: 0, waitDur: (24/4)/360, quantVal: 1/4, guiColor: Color.hsv(0,1,1));
~circ1 = ~makeAngle.(radius: 60, circleNum: 1, instrumentNum: 0, waitDur: (8/4)/360, quantVal: 1/8, guiColor: Color.hsv(0.1,1,1));
~circ2 = ~makeAngle.(radius: 80, circleNum: 2, instrumentNum: 0, waitDur: (5/4)/360, quantVal: 1/8,
	guiColor: Color.hsv(0.9,1,1)
);

~circ0_right = ~makeAngle.(radius: 40, circleNum: 3, instrumentNum: 0, waitDur: (19/4)/360, quantVal: 1/8);
~circ1_right = ~makeAngle.(radius: 60, circleNum: 4, instrumentNum: 0, waitDur: (11/4)/360, quantVal: 1/8);
~circ2_right = ~makeAngle.(radius: 80, circleNum: 5, instrumentNum: 0, waitDur: (7/4)/360, quantVal: 1/8);

~freezeLeft = false;
~freezeRight = false;

OSCdef(\points_left,{|msg|
	if(~freezeLeft.not){
		var points = msg[1..].clump(2);
		var angles;
		if(points.notEmpty){
			angles = points.collect {|p|
				[Point(p[0], p[1]).translate(~offsetLeft * -1).theta.raddeg + 180, Point(p[0], p[1]).dist(~offsetLeft).round]
			};
			// angles.postln;
		};
		~circ0.getIntersections(angles);
		~circ1.getIntersections(angles);
		~circ2.getIntersections(angles);
		{
			~gui.pointsLeftWindow.drawFunc = {
				Pen.use {
					var hits = List.new;
					[~circ0, ~circ1, ~circ2].do { |ci|
						Pen.color = Color.black();
						Pen.addOval(Rect(
							~offsetLeft.x - ci.radius,
							~offsetLeft.y - ci.radius,
							ci.circumference,
							ci.circumference));
						Pen.stroke;
						Pen.color = ci.guiColor;
						if(ci.guiHit > 0){
							hits.add([
								Rect(*(
									Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~offsetLeft).asArray  ++ [ci.guiHit, ci.guiHit]
								)),
								ci.guiColor
							]);
							ci.guiHit = ci.guiHit - 4;
						}{
							Pen.addOval(
								Rect(*(
									Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~offsetLeft).asArray  ++ [4, 4]
								))
							);
						};
						Pen.fill;
					};


					Pen.color = Color.green();
					points.do {|p|
						Pen.addRect(
							Rect(*(p ++ [5, 5]))
						);
					};
					Pen.fill;
					// Pen.color = Color.red();
					hits.do {|arr| Pen.color = arr[1]; Pen.addOval(arr[0]); Pen.fill};
					// Pen.fill;
				};
			};
			~gui.pointsLeftWindow.refresh;
		}.fork(AppClock);
	};
}, '/points_left').fix;

OSCdef(\points_right,{|msg|
	if(~freezeRight.not){
		var points = msg[1..].clump(2);
		var angles;
		if(points.notEmpty){
			angles = points.collect {|p|
				[Point(p[0], p[1]).translate(~offsetLeft * -1).theta.raddeg + 180, Point(p[0], p[1]).dist(~offsetLeft).round]
			};
			// angles.postln;
		};
		{
			~gui.pointsRightWindow.drawFunc = {
				Pen.use {
					[~circ0_right, ~circ1_right, ~circ2_right].do { |ci|
						Pen.addOval(Rect(
							~offsetLeft.x - ci.radius,
							~offsetLeft.y - ci.radius,
							ci.circumference,
							ci.circumference));
					};
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
			~gui.pointsRightWindow.refresh;
		}.fork(AppClock);

		~circ0_right.getIntersections(angles);
		~circ1_right.getIntersections(angles);
		~circ2_right.getIntersections(angles);
	}
}, '/points_right').fix;


// contours
~fps = 10;
~quantSize = 0.05;

~benniParams = ["/fmAmt", "/filterFreq", "/distortion", "/wavefrom", "/spectrum"] ++ ("/dummy" ! 100);

~contours = List.new;
OSCdef(\contour, {|msg|
	~contours.add(msg[1..].clump(2).collect{|c|c.asPoint});
}, '/contour').fix;

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
			~gui.contoursView.drawFunc_{
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
				~gui.contoursView.refresh;
				timeStep = ts;
				~quantSize.wait;
			};
			~gui.contoursView.clearDrawing;
		}.fork(AppClock);
		// audio thread
		Tdef(\contours, {
			loop {var thetaLists = List.new!40;
				"contour loop".postln;
				(0, (~quantSize * 100) .. (~fps * 100)).do {|ts|
					if(pointsWithTime[ts].notNil){
						pointsWithTime[ts].do {|pts, ix|
							//if(pts[2] == 0){
							var theta = (pts[1] - pts[0]).theta.raddeg;
							thetaLists[pts[2]].addFirst(theta);
							if(thetaLists[pts[2]].size > 14){
								var thetaAvg = (thetaLists[pts[2]].sum / 15).linlin(-180,180,40,100);
								~benniAddr.sendMsg(~benniParams[pts[2]], thetaAvg);
								//[thetaAvg, ~benniParams[pts[2]]].postln;
								thetaLists[pts[2]].pop
							};
							//}
						}
					};
					~quantSize.wait;
			}; }
		}).play;
	};
}, '/finished').fix;