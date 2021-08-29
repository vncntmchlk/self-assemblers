"resources.scd".loadRelative;
"gui_windows.scd".loadRelative;
"oscDefs.scd".loadRelative;


/// CIRCLES
~rpiAddr.sendMsg("/circles", 1);
~rpiAddr.sendMsg("/circles", 0);


Tdef(\circ0).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ1).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ2).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
~drumCircle.refreshPoints.start;

Tdef(\circ3).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ4).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ5).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
~clickCircle.refreshPoints.start;

Tdef(\circ6).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ7).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
~chordsBassCircle.refreshPoints.start;

Tdef(\circ8).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ9).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
Tdef(\circ10).play(~linkClock, doReset: true, quant: [1,0,-0.025]);
~arpCircle.refreshPoints.start;

~circ0.quantVal;
~circ0.instrumentNum;

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
