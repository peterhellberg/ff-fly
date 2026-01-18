const ff = @import("ff");

const Circle = @import("Circle.zig");

const Fly = @import("../fly.zig");

const Player = @This();

pos: ff.Point = rectCenter(Fly.SPACE),
dir: ff.Point = .{},

vec: ff.Vec = rectCenter(Fly.SPACE).vec(),
vel: ff.Vec = .{ 0, 0 },

d: i32 = Fly.SIZE_PLAYER,
f: f32 = @floatFromInt(Fly.SIZE_PLAYER),
r: f32 = 0.0,

pub fn update(p: *Player) void {
    const pd = padDir(Fly.pad);
    const spd: f32 = 2.5;

    const activeThreshold: f32 = 0.2;

    if (pd.strength > activeThreshold) {
        // Only update velocity when joystick is pushed
        p.vel = pd.dir * @as(ff.Vec, @splat(spd * pd.strength));
        p.f *= 0.9995;
    } else {
        // Apply friction to continue moving gradually
        const friction: f32 = 0.9985;
        p.vel *= @as(ff.Vec, @splat(friction));
    }

    p.d = @intFromFloat(p.f);
    p.r = Fly.pad.radius();

    const target = p.vec + p.vel;
    const targetPoint = ff.Point.from_vec(target);

    if (Fly.SPACE.contains(targetPoint)) {
        p.vec = target;
        p.pos = targetPoint;
    } else p.bounce();
}

pub const PadDir = struct {
    dir: ff.Vec,
    strength: f32,
};

/// Returns a normalized direction vector from a pad,
/// flipping Y for screen coordinates, and also returns the strength (0.0–1.0)
pub inline fn padDir(pad: ff.Pad) PadDir {
    var fx: f32 = @as(f32, @floatFromInt(pad.x));
    var fy: f32 = -@as(f32, @floatFromInt(pad.y)); // flip Y

    const deadzone: f32 = 300.0;
    if (@abs(fx) < deadzone) fx = 0;
    if (@abs(fy) < deadzone) fy = 0;

    var dir: ff.Vec = .{ fx, fy };
    const lenSq = dir[0] * dir[0] + dir[1] * dir[1];

    if (lenSq == 0) return .{ .dir = .{ 0, 0 }, .strength = 0.0 };

    const len = @sqrt(lenSq);
    dir *= @as(ff.Vec, @splat(1.0 / len));

    const strength = @min(len / 1000.0, 1.0);
    return .{ .dir = dir, .strength = strength };
}

inline fn bounce(p: *Player) void {
    if (!Fly.SPACE.contains(
        ff.Point.from_vec(.{ p.vec[0] + p.vel[0], p.vec[1] }),
    )) p.vel[0] = -p.vel[0];

    if (!Fly.SPACE.contains(
        ff.Point.from_vec(.{ p.vec[0], p.vec[1] + p.vel[1] }),
    )) p.vel[1] = -p.vel[1];

    p.vec += p.vel;
    p.pos = ff.Point.from_vec(p.vec);
}

pub fn render(p: *Player) void {
    const sp = Fly.cam.screen(p.pos);

    Circle.new(
        sp.add(ff.Point.from_vec(p.vel).mul(.new(-6, -6))),
        @intFromFloat(p.r * 0.03),
    ).draw(.{
        .stroke_color = .green,
        .stroke_width = 1,
    });

    Circle.new(sp, p.d).draw(.{
        .fill_color = .yellow,
        .stroke_color = .orange,
        .stroke_width = 1,
    });
}

pub fn circle(self: *const Player) Circle {
    return .new(self.pos, self.d);
}

fn rectCenter(r: ff.Rect) ff.Point {
    return .{
        .x = r.size.width / 2,
        .y = r.size.height / 2,
    };
}
