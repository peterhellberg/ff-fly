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
    .stroke_width = 3,
};

const PREY: ff.Style = .{
    .fill_color = .light_green,
    .stroke_color = .green,
    .stroke_width = 1,
};

pub fn spawn(self: *Enemy, wr: ff.Rect) void {
    self.pos = Random.pos(wr);

    while (Fly.cam.sees(self.pos)) {
        self.pos = Random.pos(wr);
    }

    self.vec = self.pos.vec();
    self.d = Random.mod(i32, 16) + 5;
    self.f = @floatFromInt(self.d);
}

pub fn update(self: *Enemy) void {
    const d = Fly.player.vec - self.vec;
    const l = @sqrt(d[0] * d[0] + d[1] * d[1]);

    if (l == 0) return;

    // --- Base speeds ---
    const minChaseSpeed: f32 = 0.4;
    const maxChaseSpeed: f32 = 0.8;
    const minFleeSpeed: f32 = 0.3;
    const maxFleeSpeed: f32 = 0.6;

    // --- Map center ---
    const center = Fly.SPACE.min().vec() + Fly.SPACE.size.vec() * @as(ff.Vec, .{ 0.5, 0.5 });
    const tc = center - self.vec;
    const centerLen = @sqrt(tc[0] * tc[0] + tc[1] * tc[1]);

    const maxCenterForce: f32 = 0.2;
    const centerScale: f32 = if (centerLen > 0)
        @min(centerLen / 300.0, maxCenterForce)
    else
        0.0;

    var centerVec: ff.Vec = .{ 0, 0 };
    if (centerLen != 0) centerVec = tc * @as(ff.Vec, @splat(centerScale / centerLen));

    // --- Decide speed / direction based on player size ---
    var dirSign: f32 = 1.0;
    var speed: f32 = 0;

    const fleeRadius: f32 = 160.0;

    if (self.d > Fly.player.d) {
        dirSign = 1.0;
        const sizeDiff: f32 = @floatFromInt(self.d - Fly.player.d);
        const clampedDiff = @min(sizeDiff, 30.0);

        speed = minChaseSpeed + (clampedDiff / 30.0) * (maxChaseSpeed - minChaseSpeed);
    } else {
        if (l < fleeRadius) {
            dirSign = -1.0;
            const sizeDiff: f32 = @floatFromInt(Fly.player.d - self.d);
            const clampedDiff = @min(sizeDiff, 30.0);

            speed = minFleeSpeed + (clampedDiff / 30.0) * (maxFleeSpeed - minFleeSpeed);
        } else {
            dirSign = 0.0;
            speed = 0.0;
        }
    }

    // --- Combine forces: player + gentle center ---
    const playerVec = d * @as(ff.Vec, @splat(dirSign * speed / l));
    self.dir = playerVec + centerVec;

    // --- Bounce off world edges ---
    self.bounce();

    // --- Apply movement ---
    self.vec += self.dir;
    self.pos = ff.Point.from_vec(self.vec);

    // --- Respawn / size logic ---
    if (self.f < 0 or self.d < 1) self.spawn(Fly.SPACE);
    self.d = @intFromFloat(self.f);
}

pub fn bounce(self: *Enemy) void {
    var nx = self.vec[0] + self.dir[0];
    var ny = self.vec[1] + self.dir[1];

    if (nx < Fly.SPACE.point.x) {
        self.dir[0] = -self.dir[0];
        nx = Fly.SPACE.point.x;
    } else if (nx > Fly.SPACE.point.x + Fly.SPACE.size.width) {
        self.dir[0] = -self.dir[0];
        nx = Fly.SPACE.point.x + Fly.SPACE.size.width;
    }

    if (ny < Fly.SPACE.point.y) {
        self.dir[1] = -self.dir[1];
        ny = Fly.SPACE.point.y;
    } else if (ny > Fly.SPACE.point.y + Fly.SPACE.size.height) {
        self.dir[1] = -self.dir[1];
        ny = Fly.SPACE.point.y + Fly.SPACE.size.height;
    }

    self.vec = .{ nx, ny };
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
        ff.draw.Line(pp, pp.lerp(ep, 0.1), .{ .color = .orange });
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
