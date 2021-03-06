// 0sc -params
thisProcess.openUDPPort(9010);
11.do { |sym|
	sym = ("circ" ++ sym).asSymbol;
	OSCdef((sym ++ "/onOff").asSymbol, {|msg|
		//topEnvironment[sym].sharedValues.onOff = msg[1].asBoolean;
		if(msg[1] == 1){
			if(topEnvironment[sym].sharedValues.fade.asBoolean){
				topEnvironment[sym].fadeObj.inc;
			};
			Tdef(sym).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
		}{
			if(topEnvironment[sym].sharedValues.fade.asBoolean){
				topEnvironment[sym].fadeObj.dec;
			}{
				Tdef(sym).stop;
			};
		};
	}, "/" ++ sym ++ "/onOff").fix;
};

~pitjes = (
	indexPattern: Pseq((0..1), inf).asStream,
	chords: [[0,2,7,11],[0,5,7,10]],
	index: 0,
	nextNotes: {|self| self.index = self.indexPattern.next; self.getNotes},
	getNotes: {|self| self.chords[self.index] }
);

OSCdef(\pitjes, {|msg|
	var numNotes = msg[1];
	if(msg.size > (numNotes * 2)){
		~pitjes.chords = msg[2..].clump(numNotes).postln;
		~pitjes.index = 0;
		~pitjes.indexPattern = Pseq((0..(~pitjes.chords.size - 1)), inf).asStream;
	}
}, '/field').fix;

~oscPresets = (
	presetPath: PathName(thisProcess.nowExecutingPath).pathOnly ++ "presets",
	saveThese: [
		\drumCircle, \clickCircle, \chordsBassCircle, \arpCircle,
		\circ0, \circ1, \circ2, \circ3, \circ4, \circ5, \circ6, \circ7, \circ8, \circ9, \circ10
	],
	savePreset: {|self, name = "test"|
		var preset = ();
		self.saveThese.do {|sym|
			preset[sym] = topEnvironment[sym].sharedValues.asKeyValuePairs
		};
		preset.writeArchive(self.presetPath +/+ name ++ ".preset");
	},
	loadPreset: {|self, name = "test"|
		var preset = Object.readArchive(self.presetPath +/+ name ++ ".preset");
		preset.keysValuesDo {|sym, keyValuePairs|
			keyValuePairs.pairsDo {|k, v|
				topEnvironment[sym].sharedValues[k] = v; [k, v]
			}
		}
	}
)
