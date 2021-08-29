// network connection
thisProcess.openUDPPort(8000); // philipp
thisProcess.openUDPPort(9000); // receive port from rpi
thisProcess.openUDPPort(9010); // receive port from open stage control
~rpiAddr = NetAddr("10.42.0.208", 9001); // send addr to rpi
/*~benniAddr = NetAddr("192.168.1.100", 8000); */// send addr to benni
~benniAddr = NetAddr("192.168.1.102", 8000);
~openStageControlAddr = NetAddr("127.0.0.1", 9001);

~offsetLeft = Point( 98, 135 ); //wird auch fuer rechts benutzt...
OSCdef(\resolution, { |msg|
	~resolution = msg[[1,2]].postln;
	~offsetLeft = Point(*msg[[3,4]]).postln;
	~offsetRight = Point(*msg[[5,6]]).postln;
},'/resolution').oneShot;

~linkClock = LinkClock.new(1).permanent_(true);

// ~mOut.noteOn(0, 36, 100)
{
	var amps = (4: 127, 8: 70, 16: 45);
	~quantAmps = Env([
		amps[4],amps[16],amps[8],amps[16],
		amps[4],amps[16],amps[8],amps[16],
		amps[4],amps[16],amps[8],amps[16],
		amps[4],amps[16],amps[8],amps[16],amps[4]
	],[1/4],[-4,4]);
}.value;

~makeAngle = { |radius, circleNum, instrumentNum, waitDur, quantVal = 4, guiColor, noteFunc, circleLegato = 8, muteEveryX = 0|
	var ev = (
		sharedValues: OSCSharedEvent.new(netAddr: ~openStageControlAddr, prefix: "circ" ++ circleNum),
		fadeObj: (
			val: 1,
			fadeTime: 5,
			inc: {|self|
				self.player.stop;
				self.player = {
					while {self.val <= 1}{ self.val = (self.val + 0.01).postln; (self.fadeTime * 0.01).wait }
				}.fork
			},
			dec: {|self|
				self.player.stop;
				self.player = {
					while {self.val >= 0.001}{ self.val = (self.val - 0.01).round(0.01).postln; (self.fadeTime * 0.01).wait }
				}.fork
			}
		),
		radius: radius,
		circumference: radius * 2,
		circleNum: circleNum,
		testAngle: 0,
		guiHit: 0,
		guiColor: guiColor,
		// triggerNote: {|self, vel| noteFunc.(self.circleNum, self.instrumentNum, vel, self.sharedValues.waitDur) },
		triggerNote: noteFunc,
		arpCounter: 0,
		circleLegato: circleLegato,
		muteNow: false,
		muteCount: 0,
		muteEveryX: muteEveryX,
		getIntersections: { |self, angles| self.intersections = angles.select{|ang| ang[1] == self.radius} },
		start: { |self|
			self.sharedValues.onOff = 1;
			Tdef(("circ" ++ circleNum).asSymbol, {
				inf.do {|i|
					self.testAngle = i % 360;
					// bei jedem neuen Durchlauf vom Kreis
					if(self.testAngle == 0){
						if(self.muteEveryX > 0){
							self.muteNow = (self.muteCount % self.muteEveryX) == (self.muteEveryX - 1);
							self.muteCount = self.muteCount + 1
						}
					};

					if(self.intersections.notNil && self.muteNow.not){
						self.intersections.do { |ang, ix|
							if(ang[0].asInteger == self.testAngle){
								var quantCalc = 1 / self.sharedValues.quantVal;
								self.guiHit = 16; // koennte anhand der velocity skalieren
								thisThread.clock.sched(quantCalc - thisThread.beats.mod(quantCalc),{
									var velocityOfCircle = (i % 90).fold2(45).linlin(0,44,10,127);
									var velocityOfClock = ~quantAmps[thisThread.beats.mod(4)];
									//[self.circleNum, self.instrumentNum, velocityOfClock].postln;
									self.triggerNote(velocityOfClock * self.fadeObj.val)
								})
							}
						}
					};
					(self.sharedValues.waitDur * self.sharedValues.loopSpeedLevel / 1440).wait;
				}
			}).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
		}
	);
	ev.sharedValues.onOff = 0;
	ev.sharedValues.quantVal = quantVal;
	ev.sharedValues.waitDur = waitDur;
	ev.sharedValues.loopSpeedLevel = 1;
	ev.sharedValues.instrumentNum = instrumentNum;
	ev.sharedValues.makeOSCdefsForKeys;
	ev
};

~drumNoteFunc = { |self, vel|
	~benniAddr.sendMsg("/circleNumber", self.circleNum, self.sharedValues.instrumentNum, vel)
	// [self.circleNum, self.sharedValues.instrumentNum, vel].postln
};

~chordNoteFunc = { |self, vel|
	var duration = self.sharedValues.waitDur / self.circleLegato.next; // /4 entspricht einer umkreisung
	var notes = ~pitjes.nextNotes;
	var addBenniNotes = -1 ! (7 - notes.size);
	notes = notes ++ addBenniNotes;
	~benniAddr.sendMsg("/circleNumber", *([self.circleNum, self.sharedValues.instrumentNum, vel, duration] ++ notes))
	// ([self.circleNum, self.sharedValues.instrumentNum, vel, duration] ++ notes).postln
};

~baseNoteFunc = { |self, vel|
	var duration = self.sharedValues.waitDur / self.circleLegato.next; // /4 entspricht einer umkreisung
	var note = ~pitjes.getNotes[0].postln;
	~benniAddr.sendMsg("/circleNumber", *([self.circleNum, self.sharedValues.instrumentNum, vel, duration, note]))
	// [self.circleNum, self.sharedValues.instrumentNum, vel, duration, note].postln
};

~arpeggioFunc_1 = { |self, vel|
	var duration = self.sharedValues.waitDur / self.circleLegato.next; // /4 entspricht einer umkreisung
	var note = if(self.arpCounter == 1){
		~pitjes.nextNotes.wrapAt(self.arpCounter);
	}{
		~pitjes.getNotes.wrapAt(self.arpCounter);
	};
	self.arpCounter = (self.arpCounter + 1) % 2;
	~benniAddr.sendMsg("/circleNumber", *([self.circleNum, self.sharedValues.instrumentNum, vel, duration, note]))
	// [self.circleNum, self.sharedValues.instrumentNum, vel, duration, note].postln
};

~arpeggioFunc_2 = { |self, vel|
	var duration = self.sharedValues.waitDur / self.circleLegato.next; // /4 entspricht einer umkreisung
	var note = ~pitjes.getNotes.wrapAt(self.arpCounter + 2);
	self.arpCounter = (self.arpCounter + 1) % 2;
	~benniAddr.sendMsg("/circleNumber", *([self.circleNum, self.sharedValues.instrumentNum, vel, duration, note]))
	// [self.circleNum, self.sharedValues.instrumentNum, vel, duration, note].postln
};

~arpeggioFunc_3 = { |self, vel|
	var duration = self.sharedValues.waitDur / self.circleLegato.next; // /4 entspricht einer umkreisung
	var note = ~pitjes.getNotes.wrapAt(self.arpCounter + 2);
	self.arpCounter = (self.arpCounter + 2) % 2;
	~benniAddr.sendMsg("/circleNumber", *([self.circleNum, self.sharedValues.instrumentNum, vel, duration, note]))
	// [self.circleNum, self.sharedValues.instrumentNum, vel, duration, note].postln
};

/*~drumNoteFunc = { |circleNum, instrumentNum, vel, dummy|
~benniAddr.sendMsg("/circleNumber", circleNum, instrumentNum, vel)
};

~chordNoteFunc = { |circleNum, instrumentNum, vel, waitDur|
var duration = waitDur / 8; // /4 entspricht einer umkreisung
var notes;
var addBenniNotes = -1 ! (7 - ~pitjes.size);
~pitjesIndex = ~pitjesIndexPattern.next;
notes = ~pitjes[~pitjesIndex] ++ addBenniNotes;
~benniAddr.sendMsg("/circleNumber", *([circleNum, instrumentNum, vel, duration] ++ notes))
};

~baseNoteFunc = { |circleNum, instrumentNum, vel, waitDur|
var duration = waitDur / 16; // /4 entspricht einer umkreisung
var note = ~pitjes[~pitjesIndex][0].postln;
~benniAddr.sendMsg("/circleNumber", *([circleNum, instrumentNum, vel, duration, note]))
};*/

~circ0 = ~makeAngle.(radius: 40, circleNum: 0, instrumentNum: 0, waitDur: 4, quantVal: 16, guiColor: Color.hsv(0,1,1), noteFunc: ~drumNoteFunc);
~circ1 = ~makeAngle.(radius: 60, circleNum: 1, instrumentNum: 0, waitDur: 9, quantVal: 16, guiColor: Color.hsv(0.1,1,1), noteFunc: ~drumNoteFunc);
~circ2 = ~makeAngle.(radius: 80, circleNum: 2, instrumentNum: 0, waitDur: 16, quantVal: 16,
	guiColor: Color.hsv(0.9,1,1), noteFunc: ~drumNoteFunc
);

~circ3 = ~makeAngle.(radius: 40, circleNum: 3, instrumentNum: 0, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.8,1,1), noteFunc: ~drumNoteFunc);
~circ4 = ~makeAngle.(radius: 60, circleNum: 4, instrumentNum: 0, waitDur: 16, quantVal: 8, guiColor: Color.hsv(0.7,1,1), noteFunc: ~drumNoteFunc);
~circ5 = ~makeAngle.(radius: 80, circleNum: 5, instrumentNum: 0, waitDur: 24, quantVal: 8, guiColor: Color.hsv(0.6,1,1), noteFunc: ~drumNoteFunc);

~circ6 = ~makeAngle.(
	radius: 40, circleNum: 6, instrumentNum: 0, waitDur: 32,
	quantVal: 8, guiColor: Color.hsv(0.4,1,1), noteFunc: ~baseNoteFunc,
	circleLegato: 16
);
~circ7 = ~makeAngle.(
	radius: 80, circleNum: 7, instrumentNum: 0,
	waitDur: 36, quantVal: 8, guiColor: Color.hsv(0.3,1,1), noteFunc: ~chordNoteFunc,
	circleLegato: Pseq([8,16],inf).asStream
);

~circ8 = ~makeAngle.(radius: 40, circleNum: 8, instrumentNum: 0, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.8,1,1), noteFunc: ~arpeggioFunc_1);
~circ9 = ~makeAngle.(radius: 60, circleNum: 9, instrumentNum: 0, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.7,1,1), noteFunc: ~arpeggioFunc_2);
~circ10 = ~makeAngle.(radius: 80, circleNum: 10, instrumentNum: 0, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.6,1,1), noteFunc: ~arpeggioFunc_3);
/*~circ11 = ~makeAngle.(radius: 60, circleNum: 11, instrumentNum: 0, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.5,1,1), noteFunc: ~arpeggioFunc);
~circ12 = ~makeAngle.(radius: 70, circleNum: 12, instrumentNum: 0, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.4,1,1), noteFunc: ~arpeggioFunc);
~circ13 = ~makeAngle.(radius: 80, circleNum: 13, instrumentNum: 0, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.3,1,1), noteFunc: ~arpeggioFunc);
~circ14 = ~makeAngle.(radius: 90, circleNum: 14, instrumentNum: 0, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.2,1,1), noteFunc: ~arpeggioFunc);*/



~freezeLeft = false;
~freezeRight = false;
~freezeLeft2 = true;
~freezeRight2 = true;


OSCdef(\points_left,{|msg|
	if(~freezeLeft.not){
		var points = msg[1..].clump(2);
		var angles;
		if(points.notEmpty){
			angles = points.collect {|p|
				[Point(p[0], p[1]).translate(~offsetLeft * -1).theta.raddeg + 180, Point(p[0], p[1]).dist(~offsetLeft).round]//, 4, p] // die 0 fuer color change bei intersections..
			};
			// angles.postln;
		};
		~circ0.getIntersections(angles);
		~circ1.getIntersections(angles);
		~circ2.getIntersections(angles);
		~points_left = points;
	};
	// spaeter mal sinnvoller machen
	if(~freezeLeft2.not){
		var points = msg[1..].clump(2);
		var angles;
		if(points.notEmpty){
			angles = points.collect {|p|
				[Point(p[0], p[1]).translate(~offsetLeft * -1).theta.raddeg + 180, Point(p[0], p[1]).dist(~offsetLeft).round]//, 4, p] // die 0 fuer color change bei intersections..
			};
			// angles.postln;
		};
		~circ6.getIntersections(angles);
		~circ7.getIntersections(angles);
		~points_left2 = points;
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
		~circ3.getIntersections(angles);
		~circ4.getIntersections(angles);
		~circ5.getIntersections(angles);
		~points_right = points;
	};
	if(~freezeRight2.not){
		var points = msg[1..].clump(2);
		var angles;
		if(points.notEmpty){
			angles = points.collect {|p|
				[Point(p[0], p[1]).translate(~offsetLeft * -1).theta.raddeg + 180, Point(p[0], p[1]).dist(~offsetLeft).round]
			};
		};
		~circ8.getIntersections(angles);
		~circ9.getIntersections(angles);
		~circ10.getIntersections(angles);
		/*		~circ11.getIntersections(angles);
		~circ12.getIntersections(angles);
		~circ13.getIntersections(angles);
		~circ14.getIntersections(angles);*/

		~points_right2 = points;
	};
}, '/points_right').fix;

/*

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
var pointsWithTime = List.new;
var contsNow = List.new;
contours.do {|cont, contIx|
var quant = ~fps / cont.size; // 2fps
var inc = 0;
pointsWithTime.add(Order.new(2 /~quantSize));
cont.doAdjacentPairs {|a, b|
var index = (inc.round(~quantSize) * 100).asInteger;
pointsWithTime[contIx][index] ?? { pointsWithTime[contIx][index] = List.new };
pointsWithTime[contIx][index].add([a, b]);
inc = inc + quant;
}
};
{
~gui.contoursView.drawFunc_{
Pen.scale(2,2);
contsNow.do {|cnt|
cnt.do { |pt|
​Pen.line(pt[0],pt[1]);
};
};
//​Pen.line(ptsNow.first[0],ptsNow.last[1]);
Pen.stroke;
};
}.defer;
~contours.clear;

Tdef(\contours, {
"start drawing % contours".format(contours.size).postln;

loop {var thetaLists = List.new!40;
"contour loop".postln;
AppClock.clear;
{~gui.contoursView.clearDrawing}.defer;
(0, (~quantSize * 100) .. (~fps * 100)).do {|ts, doIndex|
contsNow.clear;
pointsWithTime.do { |cont, contIx|
if(cont[ts].notNil){
contsNow.add(List.new);
cont[ts].do {|pts, ix|
var theta = (pts[1] - pts[0]).theta.raddeg;
thetaLists[contIx].addFirst(theta);
if(thetaLists[contIx].size > 14){
var thetaAvg = (thetaLists[contIx].sum / 15).linlin(-180,180,40,100);
~benniAddr.sendMsg(~benniParams[contIx], thetaAvg);
thetaLists[contIx].pop
};
contsNow.last.add(pts);
};
// contsNow.last.add([cont[ts].first[0], cont[ts].last[1]]);
};
};
{~gui.contoursView.refresh}.defer;
~quantSize.wait;
};
}
}).play;
};
}, '/finished').fix;

*/