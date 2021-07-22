thisProcess.openUDPPort(9000);
OSCdef(\resolution, { |msg|
	~resolution = msg[[1,2]].postln;
	~offsetLeft = Point(*msg[[3,4]]).postln * -1;
	~offsetRight = Point(*msg[[5,6]]).postln * -1;
},'/resolution').oneShot;

(
w = Window("left", Rect(128, 64, ~resolution[1] * 0.5, ~resolution[0] * 1));
w.front;
w.view.background = Color.white;

q = Window("right", Rect(256, 64, ~resolution[1] * 0.5, ~resolution[0] * 1));
q.front;
q.view.background = Color.white;
// ~offset = Point((w.bounds.width / 2),  (w.bounds.height / 2)) * -1
)

// benni dings
// n = NetAddr("192.168.178.29", 8000);
n = NetAddr("192.168.1.101", 8000);
n.sendMsg("/circleNumber", 0,0)


thisProcess.openUDPPort(8000);
(
~start = SystemClock.seconds;
n.sendMsg("/rtGo", 1);
OSCdef(\rtBack, { |msg| (SystemClock.seconds - ~start).postln}, "/rtBack");
)

Pbind(\dur, 2, \legato, 0.2, \freq,900, \latency, 0).play(~linkClock, quant: 4)
~linkClock = LinkClock.new(1).permanent_(true);
~linkClock.tempo = 0.5
~linkClock.delta

// winkel als velocity schicken
(
var amps = (4: 127, 8: 70, 16: 45);
~quantAmps = Env([
	amps[4],amps[16],amps[8],amps[16],
	amps[4],amps[16],amps[8],amps[16],
	amps[4],amps[16],amps[8],amps[16],
	amps[4],amps[16],amps[8],amps[16],amps[4]
],[1/4],[-4,4]);

~makeAngle = { |radius, circleNum, instrumentNum, waitDur, quantVal = 0.25|
	(
		radius: radius,
		circleNum: circleNum,
		// instrumentNum: instrumentNum,
		waitDur: waitDur,
		getIntersections: { |self, angles| self.intersections = angles.select{|ang| ang[1] == self.radius} },
		start: { |self|
			Task({
				inf.do {|i|
					if(self.intersections.notNil){
						self.intersections.do { |ang|
							if(ang[0].asInteger == (i%360)){
								thisThread.clock.sched(quantVal - thisThread.beats.mod(quantVal),{
									var velocityOfCircle = (i % 90).fold2(45).linlin(0,44,10,127);
									var velocityOfClock = ~quantAmps[thisThread.beats.mod(4)];
									[self.circleNum, instrumentNum, velocityOfClock].postln;
									n.sendMsg("/circleNumber", self.circleNum, instrumentNum, velocityOfClock)
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

​OSCdef(\points_left,{|msg|
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

}, '/points_left');

~circ0.start;
~circ1.start;
~circ2.start;
)



(
~circ0_right = ~makeAngle.(radius: 40, circleNum: 3, instrumentNum: 0, waitDur: (19/4)/360, quantVal: 1/8);
~circ1_right = ~makeAngle.(radius: 60, circleNum: 4, instrumentNum: 0, waitDur: (11/4)/360, quantVal: 1/8);
~circ2_right = ~makeAngle.(radius: 80, circleNum: 5, instrumentNum: 0, waitDur: (7/4)/360, quantVal: 1/8);

​OSCdef(\points_right,{|msg|
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

}, '/points_right');

~circ0_right.start;
~circ1_right.start;
~circ2_right.start;
)