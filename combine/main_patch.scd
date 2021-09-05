"resources.scd".loadRelative;
"gui_windows.scd".loadRelative;
"oscDefs.scd".loadRelative;

Tdef(\circ2).stop
/// CIRCLES
"python ~/Repos/self-assemblers/rec_images.py".runInTerminal

~rpiAddr.sendMsg("/circles", 1);
~rpiAddr.sendMsg("/circles", 0);

/*( sollte durch skipjack erledigt sein?
~drumCircle.refreshPoints.start;
~clickCircle.refreshPoints.start;
~chordsBassCircle.refreshPoints.start;
~arpCircle.refreshPoints.start;
)*/
~oscPresets.savePreset("default")
~oscPresets.loadPreset("default")

~circ0.sharedValues.getPrefix

Tdef(\circ0).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ1).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ2).play(~linkClock, doReset: true, quant: [1,0,-0.025]);

Tdef(\circ3).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ4).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ5).play(~linkClock, doReset: true, quant: [1,0,-0.025]);

Tdef(\circ6).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ7).play(~linkClock, doReset: true, quant: [1,0,-0.025]);

Tdef(\circ8).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ9).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ10).play(~linkClock, doReset: true, quant: [1,0,-0.025]);

~circ0.quantVal;
~circ0.sharedValues.instrumentNum = 10

~circ7.sharedValues.waitDur = 32

// ~mOut = ConnectVirmidi(0);
// ~mOut.noteOn(0, 36, 100)
//
// // CONTOURS
// ~rpiAddr.sendMsg("/takePic");
// Tdef(\contours).stop;
//
// // contours
// ~fps = 2;
// ~quantSize = 0.05;
//
// // to do: contours drone
// Ndef(\drone, { Resonz.ar(PinkNoise.ar(), \ffreq.kr(200)) ! 2 }).play
// s.latency = nil
// Ndef(\drone).set(\ffreq, 500)
