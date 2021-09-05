~gui = ();
~gui.resolution = [ 270, 392 ];
~gui.offset = Point( 196, 135 ); //wird auch fuer rechts benutzt...
~gui.fps = 20;
~gui.res2 = ~gui.resolution * 2;

~gui.window = Window("circles", Rect(0, 0, ~gui.resolution[1] * 4 + 6, ~gui.resolution[0] * 4 + 6));
~gui.window.view.background = Color.black;
~gui.window.front;


~drumCircle.view = UserView(~gui.window, Rect(2, 2, ~gui.res2[1], ~gui.res2[0])).background_(Color.white);
~clickCircle.view = UserView(~gui.window, Rect(2, ~gui.res2[0] + 4, ~gui.res2[1], ~gui.res2[0])).background_(Color.white);
~chordsBassCircle.view = UserView(~gui.window, Rect(~gui.res2[1] + 4, 2, ~gui.res2[1], ~gui.res2[0])).background_(Color.white);
~arpCircle.view = UserView(~gui.window, Rect(~gui.res2[1] + 4, ~gui.res2[0] + 4, ~gui.res2[1], ~gui.res2[0])).background_(Color.white);

/*~drumCircle.window = Window("drum", Rect(0, 64, ~gui.resolution[1] * 2, ~gui.resolution[0] * 2));
~drumCircle.window.front;
~drumCircle.window.view.background = Color.white;

~clickCircle.window = Window("clicks", Rect(~gui.resolution[1], 64, ~gui.resolution[1] * 2, ~gui.resolution[0] * 2));
~clickCircle.window.front;
~clickCircle.window.view.background = Color.white;

~chordsBassCircle.window = Window("chords bass", Rect(~gui.resolution[1] * 2, 64, ~gui.resolution[1] * 2, ~gui.resolution[0] * 2));
~chordsBassCircle.window.front;
~chordsBassCircle.window.view.background = Color.white;

~arpCircle.window = Window("arp", Rect(~gui.resolution[1] * 3, 64, ~gui.resolution[1] * 2, ~gui.resolution[0] * 2));
~arpCircle.window.front;
~arpCircle.window.view.background = Color.white;*/

~gui.refreshPoints = SkipJack(
	updateFunc: {~gui.window.refresh},
	dt: (1 / ~gui.fps)
);

[~drumCircle, ~clickCircle, ~chordsBassCircle, ~arpCircle].do {|instrumentCircle|
	instrumentCircle.view.drawFunc = {
		Pen.scale(2,2);
		Pen.stringAtPoint(instrumentCircle.guiText, 4@5, Font("Hack", 16), Color.black);
		Pen.use {
			var hits = List.new;
			instrumentCircle.circs.do { |ci|
				if(ci.sharedValues.onOff.asBoolean){
					Pen.color = Color.black();
					Pen.addOval(Rect(
						~gui.offset.x - ci.radius,
						~gui.offset.y - ci.radius,
						ci.circumference,
						ci.circumference));
					Pen.stroke;

					Pen.color = ci.guiColor;
					if(ci.guiHit > 0){
						hits.add([
							Rect(*(
								Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~gui.offset - (ci.guiHit * 0.5)).asArray  ++ [ci.guiHit, ci.guiHit]
							)),
							ci.guiColor
						]);
						ci.guiHit = ci.guiHit - 8;
					}{
						Pen.addOval(
							Rect(*(
								Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~gui.offset - 2).asArray  ++ [4, 4]
							))
						);
					};
					Pen.fill;

				};
			};
			if(instrumentCircle.sharedValues.freezeMe.asBoolean){
				Pen.color = Color.black();
			}{
				Pen.color = Color.green();
			};
			instrumentCircle.points.do {|p|
				Pen.addRect(
					Rect(*(p ++ [4, 4]))
				);
			};
			Pen.fill;
			hits.do {|arr| Pen.color = arr[1]; Pen.addOval(arr[0]); Pen.fill};
		};
	};

	/*instrumentCircle.refreshPoints = Task({
	loop {
	instrumentCircle.window.refresh;
	(1 / ~gui.fps).wait;
	};
	}, AppClock);*/

	/*	instrumentCircle.refreshPoints = SkipJack(
	updateFunc: {instrumentCircle.window.refresh},
	dt: (1 / ~gui.fps)
	);*/
};
/*~gui.pointsLeftWindow = Window("left", Rect(0, 64, ~resolution[1], ~resolution[0] * 2));
~gui.pointsLeftWindow.front;
~gui.pointsLeftWindow.view.background = Color.white;

~gui.pointsRightWindow = Window("right", Rect(~resolution[1], 64, ~resolution[1], ~resolution[0] * 2));
~gui.pointsRightWindow.front;
~gui.pointsRightWindow.view.background = Color.white;

~gui.pointsLeft2Window = Window("Left2", Rect(~resolution[1] * 2, 64, ~resolution[1], ~resolution[0] * 2));
~gui.pointsLeft2Window.front;
~gui.pointsLeft2Window.view.background = Color.white;

~gui.pointsRight2Window = Window("Right2", Rect(~resolution[1] * 3, 64, ~resolution[1], ~resolution[0] * 2));
~gui.pointsRight2Window.front;
~gui.pointsRight2Window.view.background = Color.white;

/*
~gui.contoursWindow = Window("contours", Rect(~resolution[1] * 3, 64, ~resolution[1] * 2,~resolution[0] * 2));
​
~gui.contoursView = UserView(~gui.contoursWindow, ~gui.contoursWindow.view.bounds)
.clearOnRefresh_(false)
.background_(Color.white);

~gui.contoursWindow.front;
*/


///
~gui.pointsLeftWindow.drawFunc = {
Pen.scale(2,2);
Pen.use {
var hits = List.new;
[~circ0, ~circ1, ~circ2].do { |ci|
if(ci.sharedValues.onOff.asBoolean){
Pen.color = Color.black();
Pen.addOval(Rect(
~offsetLeft.x - ci.radius,
~offsetLeft.y - ci.radius,
ci.circumference,
ci.circumference));
Pen.stroke;

Pen.color = ci.guiColor;
if(ci.guiHit > 0){
hits.add([
Rect(*(
Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~offsetLeft - (ci.guiHit * 0.5)).asArray  ++ [ci.guiHit, ci.guiHit]
)),
ci.guiColor
]);
ci.guiHit = ci.guiHit - 8;
}{
Pen.addOval(
Rect(*(
Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~offsetLeft - 2).asArray  ++ [4, 4]
))
);
};
Pen.fill;

};
};

if(~freezeLeft){
Pen.color = Color.black();
}{
Pen.color = Color.green();
};
~points_left.do {|p|
Pen.addRect(
Rect(*(p ++ [4, 4]))
);
};
Pen.fill;

hits.do {|arr| Pen.color = arr[1]; Pen.addOval(arr[0]); Pen.fill};
};
};

~gui.pointsLeftRefresh = Task({
loop {
~gui.pointsLeftWindow.refresh;
(1 / ~gui.fps).wait;
};
}, AppClock);

//
~points_right = [];
~gui.pointsRightWindow.drawFunc = {
Pen.scale(2,2);
Pen.use {
var hits = List.new;
[~circ3, ~circ4, ~circ5].do { |ci|
if(ci.sharedValues.onOff.asBoolean){
Pen.color = Color.black();
Pen.addOval(Rect(
~offsetLeft.x - ci.radius,
~offsetLeft.y - ci.radius,
ci.circumference,
ci.circumference));
Pen.stroke;

Pen.color = ci.guiColor;
if(ci.guiHit > 0){
hits.add([
Rect(*(
Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~offsetLeft).asArray  ++ [ci.guiHit, ci.guiHit]
)),
ci.guiColor
]);
ci.guiHit = ci.guiHit - 4;
}{
Pen.addOval(
Rect(*(
Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~offsetLeft).asArray  ++ [4, 4]
))
);
};
Pen.fill;
};
};
if(~freezeRight){
Pen.color = Color.black();
}{
Pen.color = Color.green();
};
~points_right.do {|p|
Pen.addRect(
Rect(*(p ++ [5, 5]))
);
};
Pen.fill;
// Pen.color = Color.red();
hits.do {|arr| Pen.color = arr[1]; Pen.addOval(arr[0]); Pen.fill};
// Pen.fill;
};
};

~gui.pointsRightRefresh = Task({
loop {
~gui.pointsRightWindow.refresh;
(1 / ~gui.fps).wait;
}
}, AppClock);


//
~points_left2 = [];
~gui.pointsLeft2Window.drawFunc = {
Pen.scale(2,2);
Pen.use {
var hits = List.new;
[~circ6, ~circ7].do { |ci|
if(ci.sharedValues.onOff.asBoolean){
Pen.color = Color.black();
Pen.addOval(Rect(
~offsetLeft.x - ci.radius,
~offsetLeft.y - ci.radius,
ci.circumference,
ci.circumference));
Pen.stroke;

Pen.color = ci.guiColor;
if(ci.guiHit > 0){
hits.add([
Rect(*(
Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~offsetLeft).asArray  ++ [ci.guiHit, ci.guiHit]
)),
ci.guiColor
]);
ci.guiHit = ci.guiHit - 4;
}{
Pen.addOval(
Rect(*(
Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~offsetLeft).asArray  ++ [4, 4]
))
);
};
Pen.fill;
};
};
if(~freezeLeft2){
Pen.color = Color.black();
}{
Pen.color = Color.green();
};
~points_left2.do {|p|
Pen.addRect(
Rect(*(p ++ [5, 5]))
);
};
Pen.fill;
// Pen.color = Color.red();
hits.do {|arr| Pen.color = arr[1]; Pen.addOval(arr[0]); Pen.fill};
// Pen.fill;
};
};

~gui.pointsLeft2Refresh = Task({
loop {
~gui.pointsLeft2Window.refresh;
(1 / ~gui.fps).wait;
}
}, AppClock);


//
~points_right2 = [];
~gui.pointsRight2Window.drawFunc = {
Pen.scale(2,2);
Pen.use {
var hits = List.new;
[~circ8, ~circ9, ~circ10].do { |ci| //, ~circ11, ~circ12, ~circ13, ~circ14
if(ci.sharedValues.onOff.asBoolean){
Pen.color = Color.black();
Pen.addOval(Rect(
~offsetLeft.x - ci.radius,
~offsetLeft.y - ci.radius,
ci.circumference,
ci.circumference));
Pen.stroke;

Pen.color = ci.guiColor;
if(ci.guiHit > 0){
hits.add([
Rect(*(
Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~offsetLeft).asArray  ++ [ci.guiHit, ci.guiHit]
)),
ci.guiColor
]);
ci.guiHit = ci.guiHit - 4;
}{
Pen.addOval(
Rect(*(
Point(ci.radius,0).rotate((ci.testAngle - 180).degrad).translate(~offsetLeft).asArray  ++ [4, 4]
))
);
};
Pen.fill;
};
};
if(~freezeRight2){
Pen.color = Color.black();
}{
Pen.color = Color.green();
};
~points_right2.do {|p|
Pen.addRect(
Rect(*(p ++ [5, 5]))
);
};
Pen.fill;
// Pen.color = Color.red();
hits.do {|arr| Pen.color = arr[1]; Pen.addOval(arr[0]); Pen.fill};
// Pen.fill;
};
};

~gui.pointsRight2Refresh = Task({
loop {
~gui.pointsRight2Window.refresh;
(1 / ~gui.fps).wait;
}
}, AppClock);*/