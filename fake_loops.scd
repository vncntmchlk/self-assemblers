MIDIClient.init
~mOut = ConnectVirmidi()
~mOut.noteOn(0,36,100)
[
	[3, 38],
	[4, 37],
	[5, 36]
].do { |arr|
	Pbind(
		\type, \midi,
		\midiout, ~mOut,
		\chan,0,
		\dur, (arr[0] / 4) * Pseq([1/2,1/2],inf),
		\legato, 0.5,
		//\lag, Pfunc {|ev| [0, ev.dur / 2] },
		\midinote, arr[1] //+ [12, 19]
	).play
};

[
	[2, 38],
	[9, 37],
	[12, 36]
].do { |arr|
	Pbind(
		\type, \midi,
		\midiout, ~mOut,
		\chan,0,
		\dur, (arr[0] / 4) * Pseq([1 + 2.5.rand,1 + 8.5.rand, 1+ 3.5.rand].normalizeSum,inf),
		\legato, 0.5,
		//\lag, Pfunc {|ev| [0, ev.dur / 2] },
		\midinote, arr[1] //+ [12, 19]
	).play
};