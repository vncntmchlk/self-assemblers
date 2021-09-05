(
"resources.scd".loadRelative;
"gui_windows.scd".loadRelative;
"oscDefs.scd".loadRelative;
)

"python ~/Repos/self-assemblers/rec_images.py".runInTerminal;

/// CIRCLES
~rpiAddr.sendMsg("/circles", 1);
~rpiAddr.sendMsg("/circles", 0);

~oscPresets.savePreset("x")
~oscPresets.loadPreset("slowDrums")

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

// ~mOut = ConnectVirmidi(0);
// ~mOut.noteOn(0, 36, 100)