const ff = @import("ff");

const Circle = @import("Circle.zig");
const Random = @import("Random.zig");

const Fly = @import("../fly.zig");

const Enemy = @This();

pos: ff.Point = .{},
vec: ff.Vec = .{ 0, 0 },
dir: ff.Vec = .{ 0, 0 },
f: f32 = 10.0,
d: i32 = 10,

const SPEED: f32 = 0.5;

const PRED: ff.Style = .{
    .fill_color = .red,
    .stroke_color = .purple,
    .stroke_width = 2,
};

const PREY: ff.Style = .{
    .fill_color = .white,
    .stroke_color = .light_gray,
};

pub fn spawn(self: *Enemy, wr: ff.Rect) void {
    self.pos = Random.pos(wr);

    while (dist(self.pos, Fly.player.pos) < 100) {
        self.pos = Random.pos(wr);
    }

    self.vec = self.pos.vec();
    self.d = Random.mod(i32, 15) + 5;
    self.f = @floatFromInt(self.d);
}

pub fn update(self: *Enemy) void {
    const d = Fly.player.pos.vec() - self.vec;
    const l = @sqrt(d[0] * d[0] + d[1] * d[1]);

    if (l == 0) return;

    const ds: f32 = if (Fly.player.d >= self.d) 0.4 else 0.8;
    const mv = d * @as(ff.Vec, @splat(ds * @as(f32, SPEED) / l));

    self.vec += mv;

    self.pos = ff.Point.new(
        @as(i32, @intFromFloat(@round(self.vec[0]))),
        @as(i32, @intFromFloat(@round(self.vec[1]))),
    );

    self.f -= 0.01;
    if (self.f <= 0) self.spawn(Fly.SPACE);

    self.d = @intFromFloat(self.f);

    if (!Fly.SPACE.contains(self.pos)) self.spawn(Fly.SPACE);

    self.dir = mv;
}

pub fn circle(self: *const Enemy) Circle {
    return .new(self.pos, self.d);
}

fn rect(self: *const Enemy) ff.Rect {
    return self.pos
        .sub(.new(self.d, self.d))
        .rect(.new(self.d, self.d));
}

pub fn line(self: *const Enemy) void {
    const ep = Fly.cam.screen(self.pos);
    const pp = Fly.cam.screen(Fly.player.pos);

    if (self.d < Fly.player.d) {
        ff.draw.Line(pp, ep, .{ .color = .dark_gray });
    }
}

pub fn render(self: *const Enemy) void {
    const er = self.rect();
    const ep = Fly.cam.screen(self.pos);

    const s = if (self.d > Fly.player.d) PRED else PREY;

    if (Fly.cam.intersects(er)) {
        Circle.drawCentered(ep, self.d, s);

        ff.draw.Point(ep, s.stroke_color);
    }
}

fn dist(a: ff.Point, b: ff.Point) f32 {
    const dx: f32 = @floatFromInt(b.x - a.x);
    const dy: f32 = @floatFromInt(b.y - a.y);

    return @sqrt(dx * dx + dy * dy);
}
