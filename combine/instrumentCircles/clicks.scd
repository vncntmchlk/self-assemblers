// clicks
~clickNoteFunc = { |self, vel|
	~benniAddr.sendMsg("/circleNumber", self.circleNum, self.sharedValues.instrumentNum, vel);
	~mOut.noteOn(self.sharedValues.instrumentNum, self.circleNum.mod(3) + 36,100)
	// [self.circleNum, self.sharedValues.instrumentNum, vel].postln
};
~circ3 = ~makeAngle.(radius: 60, circleNum: 3, instrumentNum: 0, waitDur: 8, quantVal: 12, guiColor: Color.hsv(0.8,1,1), noteFunc: ~clickNoteFunc);
~circ4 = ~makeAngle.(radius: 90, circleNum: 4, instrumentNum: 0, waitDur: 8, quantVal: 12, guiColor: Color.hsv(0.7,1,1), noteFunc: ~clickNoteFunc);
~circ5 = ~makeAngle.(radius: 120, circleNum: 5, instrumentNum: 0, waitDur: 8, quantVal: 12, guiColor: Color.hsv(0.6,1,1), noteFunc: ~clickNoteFunc);

~clickCircle = (
	circs: [~circ3, ~circ4, ~circ5],
	sharedValues: OSCSharedEvent.new(netAddr: ~openStageControlAddr, prefix: "clicks"),
	points: [],
	guiText: "CLICKS"
);
~clickCircle.sharedValues.freezeMe = true;
~clickCircle.sharedValues.makeOSCdefsForKeys;