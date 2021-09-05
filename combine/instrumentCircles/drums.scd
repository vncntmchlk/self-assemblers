// drums
~drumNoteFunc = { |self, vel|
	~benniAddr.sendMsg("/circleNumber", self.circleNum, self.sharedValues.instrumentNum, vel)
	// [self.circleNum, self.sharedValues.instrumentNum, vel].postln
};
~circ0 = ~makeAngle.(radius: 60, circleNum: 0, instrumentNum: 0, waitDur: 4, quantVal: 16, guiColor: Color.hsv(0,1,1), noteFunc: ~drumNoteFunc);
~circ1 = ~makeAngle.(radius: 90, circleNum: 1, instrumentNum: 0, waitDur: 9, quantVal: 16, guiColor: Color.hsv(0.1,1,1), noteFunc: ~drumNoteFunc);
~circ2 = ~makeAngle.(radius: 120, circleNum: 2, instrumentNum: 0, waitDur: 16, quantVal: 16,
	guiColor: Color.hsv(0.9,1,1), noteFunc: ~drumNoteFunc
);
~drumCircle = (
	circs: [~circ0, ~circ1, ~circ2],
	sharedValues: OSCSharedEvent.new(netAddr: ~openStageControlAddr, prefix: "drum"),
	points: [],
	guiText: "DRUMS"
);
~drumCircle.sharedValues.freezeMe = true;
~drumCircle.sharedValues.makeOSCdefsForKeys;