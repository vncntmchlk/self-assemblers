// chords and bass
~chordNoteFunc = { |self, vel|
	var duration = self.sharedValues.waitDur * self.circleLegato.next; // /4 entspricht einer umkreisung
	var notes = ~pitjes.nextNotes;
	var addBenniNotes = -1 ! (7 - notes.size);
	notes = notes ++ addBenniNotes;
	~benniAddr.sendMsg("/circleNumber", *([self.circleNum, self.sharedValues.instrumentNum, vel, duration] ++ notes))
	// ([self.circleNum, self.sharedValues.instrumentNum, vel, duration] ++ notes).postln
};
~bassNoteFunc = { |self, vel|
	var duration = self.sharedValues.waitDur * self.circleLegato.next; // /4 entspricht einer umkreisung
	var note = ~pitjes.getNotes[0].postln;
	~benniAddr.sendMsg("/circleNumber", *([self.circleNum, self.sharedValues.instrumentNum, vel, duration, note]))
	// [self.circleNum, self.sharedValues.instrumentNum, vel, duration, note].postln
};

~bassNoteFunc_chooseNearest = { |self, vel|
	var duration = self.sharedValues.waitDur * self.circleLegato.next; // /4 entspricht einer umkreisung
	var note;
	if(~lastBassNote.isNil){
		note = ~pitjes.getNotes[0].postln;
	}{
		note = ~lastBassNote.nearestInList(~pitjes.getNotes);
	};
	~lastBassNote = note;
	~benniAddr.sendMsg("/circleNumber", *([self.circleNum, self.sharedValues.instrumentNum, vel, duration, note]))
	// [self.circleNum, self.sharedValues.instrumentNum, vel, duration, note].postln
};

~circ6 = ~makeAngle.(
	radius: 60, circleNum: 6, instrumentNum: 0, waitDur: 32,
	quantVal: 8, guiColor: Color.hsv(0.4,1,1), noteFunc: ~bassNoteFunc,
	circleLegato: 1/16
);
~circ7 = ~makeAngle.(
	radius: 90, circleNum: 7, instrumentNum: 0,
	waitDur: 36, quantVal: 8, guiColor: Color.hsv(0.3,1,1), noteFunc: ~chordNoteFunc,
	circleLegato: 1/8 // Pseq([1/8,1/16],inf).asStream
);

~chordsBassCircle = (
	circs: [~circ6, ~circ7],
	sharedValues: OSCSharedEvent.new(netAddr: ~openStageControlAddr, prefix: "chordsBass"),
	points: [],
	guiText: "CHORDS BASS"
);
~chordsBassCircle.sharedValues.freezeMe = true;
~chordsBassCircle.sharedValues.makeOSCdefsForKeys;