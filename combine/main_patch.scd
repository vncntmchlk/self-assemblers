/*
drei rhythmische Schichten:
1. Drums
-drei Kreise, midinotes 36,37,38 Chan 0, medium tempo
2. Clicks/Grains
-drei Kreise, midinotes .. Chan 1, high tempo
3. Chords
-zwei Kreise, midinotes von philipp, slow tempo

*/

~mOut = ConnectVirmidi(0);
~mOut.noteOn(0, 36, 100)

"resources.scd".loadRelative;
"gui_windows.scd".loadRelative;
"oscDefs.scd".loadRelative;


/// CIRCLES
~rpiAddr.sendMsg("/circles",1);
~circ0.start; // fuer .stop usw.
~circ1.start;
~circ2.start;
~gui.pointsLeftRefresh.start;

~freezeLeft = false;
~freezeRight = false;
~freezeLeft2 = false;
~freezeRight2 = false;

~circ3.start;
~circ4.start;
~circ5.start;
~gui.pointsRightRefresh.start;

~circ6.start;
~circ7.start;
~gui.pointsLeft2Refresh.start;


~circ8.start;
~circ9.start;
~circ10.start;
~gui.pointsRight2Refresh.start;


~rpiAddr.sendMsg("/circles", 0);


~circ0.quantVal;
~circ0.instrumentNum;

~circ7.sharedValues.waitDur = 32


// CONTOURS
~rpiAddr.sendMsg("/takePic");
Tdef(\contours).stop;

// contours
~fps = 2;
~quantSize = 0.05;

// to do: contours drone
Ndef(\drone, { Resonz.ar(PinkNoise.ar(), \ffreq.kr(200)) ! 2 }).play
s.latency = nil
Ndef(\drone).set(\ffreq, 500)
