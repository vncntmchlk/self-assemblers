~resolution = [ 270, 392 ];//[ 290, 398 ];

w = Window("left", Rect(128, 64, ~resolution[1] * 0.5, ~resolution[0] * 1));
w.front;
w.view.background = Color.white;

q = Window("right", Rect(256, 64, ~resolution[1] * 0.5, ~resolution[0] * 1));
q.front;
q.view.background = Color.white;

c = Window("contours", Rect(128, 64, 382,316));
​
v = UserView(c, c.view.bounds)
.clearOnRefresh_(false)
.background_(Color.white);

c.front;