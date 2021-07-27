~resolution = [ 270, 392 ];//[ 290, 398 ];
~gui = ();
~gui.pointsLeftWindow = Window("left", Rect(128, 64, ~resolution[1] * 0.5, ~resolution[0] * 1));
~gui.pointsLeftWindow.front;
~gui.pointsLeftWindow.view.background = Color.white;

~gui.pointsRightWindow = Window("right", Rect(256, 64, ~resolution[1] * 0.5, ~resolution[0] * 1));
~gui.pointsRightWindow.front;
~gui.pointsRightWindow.view.background = Color.white;

~gui.contoursWindow = Window("contours", Rect(128, 64, 382,316));
​
~gui.contoursView = UserView(~gui.contoursWindow, ~gui.contoursWindow.view.bounds)
.clearOnRefresh_(false)
.background_(Color.white);

~gui.contoursWindow.front;