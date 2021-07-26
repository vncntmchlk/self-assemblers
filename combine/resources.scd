// network connection
thisProcess.openUDPPort(9000); // receive port from rpi
~rpiAddr = NetAddr("192.168.1.102", 9001); // send addr to rpi
~benniAddr = NetAddr("192.168.1.100", 8000); // send addr to benni

~offsetLeft = Point( 98, 135 ) * -1; //wird auch fuer rechts benutzt...
OSCdef(\resolution, { |msg|
	~resolution = msg[[1,2]].postln;
	~offsetLeft = Point(*msg[[3,4]]).postln * -1;
	~offsetRight = Point(*msg[[5,6]]).postln * -1;
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

~makeAngle = { |radius, circleNum, instrumentNum, waitDur, quantVal = 0.25|
	(
		radius: radius,
		circleNum: circleNum,
		quantVal: quantVal,
		instrumentNum: instrumentNum,
		waitDur: waitDur,
		getIntersections: { |self, angles| self.intersections = angles.select{|ang| ang[1] == self.radius} },
		start: { |self|
			Task({
				inf.do {|i|
					if(self.intersections.notNil){
						self.intersections.do { |ang|
							if(ang[0].asInteger == (i%360)){
								thisThread.clock.sched(self.quantVal - thisThread.beats.mod(self.quantVal),{
									var velocityOfCircle = (i % 90).fold2(45).linlin(0,44,10,127);
									var velocityOfClock = ~quantAmps[thisThread.beats.mod(4)];
									[self.circleNum, self.instrumentNum, velocityOfClock].postln;
									~benniAddr.sendMsg("/circleNumber", self.circleNum, self.instrumentNum, velocityOfClock)
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

~circ0 = ~makeAngle.(radius: 40, circleNum: 0, instrumentNum: 0, waitDur: (24/4)/360, quantVal: 1/4);
~circ1 = ~makeAngle.(radius: 60, circleNum: 1, instrumentNum: 0, waitDur: (4/4)/360, quantVal: 1/8);
~circ2 = ~makeAngle.(radius: 80, circleNum: 2, instrumentNum: 0, waitDur: (5/16)/360, quantVal: 1/8);

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
				[Point(p[0], p[1]).translate(~offsetLeft).theta.raddeg + 180, Point(p[0], p[1]).dist(~offsetLeft * -1).round]
			};
			// angles.postln;
		};
		{
			w.drawFunc = {
				Pen.use {
					Pen.addOval(Rect(~offsetLeft.x * -1 -40,~offsetLeft.y * -1 -40,80,80));
					Pen.addOval(Rect(~offsetLeft.x * -1 - 60,~offsetLeft.y * -1 -60,120,120));
					Pen.addOval(Rect(~offsetLeft.x * -1 - 80,~offsetLeft.y * -1 -80,160,160));
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

		~circ0.getIntersections(angles);
		~circ1.getIntersections(angles);
		~circ2.getIntersections(angles);
	};
}, '/points_left').fix;

OSCdef(\points_right,{|msg|
	if(~freezeRight.not){
		var points = msg[1..].clump(2);
		var angles;
		if(points.notEmpty){
			angles = points.collect {|p|
				[Point(p[0], p[1]).translate(~offsetLeft).theta.raddeg + 180, Point(p[0], p[1]).dist(~offsetLeft * -1).round]
			};
			// angles.postln;
		};
		{
			q.drawFunc = {
				Pen.use {
					Pen.addOval(Rect(~offsetLeft.x * -1 -40,~offsetLeft.y * -1 -40,80,80));
					Pen.addOval(Rect(~offsetLeft.x * -1 - 60,~offsetLeft.y * -1 -60,120,120));
					Pen.addOval(Rect(~offsetLeft.x * -1 - 80,~offsetLeft.y * -1 -80,160,160));
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
			q.refresh;
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
		/*{
		var thetaLists = List.new!40;
		(0, (~quantSize * 100) .. (~fps * 100)).do {|ts|
		if(pointsWithTime[ts].notNil){
		pointsWithTime[ts].do {|pts, ix|
		//if(pts[2] == 0){
		var theta = (pts[1] - pts[0]).theta.raddeg;
		thetaLists[pts[2]].addFirst(theta);
		if(thetaLists[pts[2]].size > 14){
		var thetaAvg = (thetaLists[pts[2]].sum / 15).linlin(-180,180,0,100);
		//~benniAddr.sendMsg("/freq" ++ (pts[2] + 1),thetaAvg);
		[thetaAvg, pts[2]].postln;
		thetaLists[pts[2]].pop
		};
		//}
		}
		};
		~quantSize.wait;
		};
		}.fork*/
	};
}, '/finished').fix;