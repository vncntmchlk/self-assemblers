"gui_windows.scd".loadRelative;

"resources.scd".loadRelative;


// CONTOURS
~rpiAddr.sendMsg("/takePic");
Tdef(\contours).stop;

// contours
~fps = 1.5;
~quantSize = 0.05;




/// CIRCLES
~rpiAddr.sendMsg("/circles",1);

~circ0Player = ~circ0.start; // fuer .stop usw.
~circ1Player = ~circ1.start;
~circ2Player = ~circ2.start;

~circ0_rightPlayer = ~circ0_right.start;
~circ1_rightPlayer = ~circ1_right.start;
~circ2_rightPlayer = ~circ2_right.start;


~rpiAddr.sendMsg("/circles", 0);

~circ0Player.stop;
~circ1Player.stop;
~circ2Player.stop;

~circ0_rightPlayer.stop;
~circ1_rightPlayer.stop;
~circ2_rightPlayer.stop;

~circ0.quantVal;
~circ0.instrumentNum;
~circ0.waitDur;
