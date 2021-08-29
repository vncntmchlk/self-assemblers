// 0sc -params
// pro kreis- onOff (auch bei visuals?), quant, dur
thisProcess.openUDPPort(9010);
[\circ0, \circ1, \circ2, \circ3, \circ4, \circ5, \circ6, \circ7, \circ8, \circ9, \circ10].do { |sym|
	/*	OSCdef((sym ++ "/quant").asSymbol, {|msg|
	topEnvironment[sym].quantVal = 1 / msg[1];
	}, "/" ++ sym ++ "/quant").fix;

	OSCdef((sym ++ "/dur").asSymbol, {|msg|
	topEnvironment[sym].waitDur = (msg[1] / 4) / 360;
	}, "/" ++ sym ++ "/dur").fix;*/

	OSCdef((sym ++ "/onOff").asSymbol, {|msg|
		//topEnvironment[sym].sharedValues.onOff = msg[1].asBoolean;
		if(msg[1] == 1){
			Tdef(sym).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
		}{
			Tdef(sym).stop;
		};
	}, "/" ++ sym ++ "/onOff").fix;

	OSCdef((sym ++ "/onOffFade").asSymbol, {|msg|
		if(msg[1] == 1){
			topEnvironment[sym].fadeObj.inc;
			Tdef(sym).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
		}{
			topEnvironment[sym].fadeObj.dec;
			Tdef(sym).stop;
		};
	}, "/" ++ sym ++ "/onOffFade").fix;
};

OSCdef(\freezeLeft, {|msg|
	~freezeLeft = msg[1].asBoolean;
}, "/freezeLeft").fix;

OSCdef(\freezeRight, {|msg|
	~freezeRight = msg[1].asBoolean;
}, "/freezeRight").fix;

OSCdef(\freezeLeft2, {|msg|
	~freezeLeft2 = msg[1].asBoolean;
}, "/freezeLeft2").fix;

OSCdef(\freezeRight2, {|msg|
	~freezeRight2 = msg[1].asBoolean;
}, "/freezeRight2").fix;

~pitjes = (
	indexPattern: Pseq((0..1), inf).asStream,
	chords: [[0,2,7,11],[0,5,7,10]],
	index: 0,
	nextNotes: {|self| self.index = self.indexPattern.next; self.getNotes},
	getNotes: {|self| self.chords[self.index] }
);

OSCdef(\pitjes, {|msg|
	var numNotes = msg[1];
	if(numNotes > 1){
		~pitjes.chords = msg[2..].clump(numNotes).postln;
		~pitjes.indexPattern = Pseq((0..(~pitjes.chords.size - 1)), inf).asStream;
	}
}, '/field').fix;

// evtl reset fuer alle damit sie synchron auf der naechsten 1 starten?
