// arp
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
~circ8 = ~makeAngle.(radius: 60, circleNum: 8, instrumentNum: 0, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.8,1,1), noteFunc: ~arpeggioFunc_1);
~circ9 = ~makeAngle.(radius: 90, circleNum: 9, instrumentNum: 1, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.7,1,1), noteFunc: ~arpeggioFunc_2);
~circ10 = ~makeAngle.(radius: 120, circleNum: 10, instrumentNum: 2, waitDur: 8, quantVal: 8, guiColor: Color.hsv(0.6,1,1), noteFunc: ~arpeggioFunc_3);

~arpCircle = (
	circs: [~circ8, ~circ9, ~circ10],
	sharedValues: OSCSharedEvent.new(netAddr: ~openStageControlAddr, prefix: "arp"),
	points: [],
	guiText: "ARPEGGIATOR"
);
~arpCircle.sharedValues.freezeMe = true;
~arpCircle.sharedValues.makeOSCdefsForKeys;