const ff = @import("ff");

const Circle = @import("Circle.zig");

const Fly = @import("../fly.zig");

const Player = @This();

pos: ff.Point = rectCenter(Fly.SPACE),
dir: ff.Point = .{},

d: i32 = Fly.SIZE_PLAYER,
f: f32 = @floatFromInt(Fly.SIZE_PLAYER),

pub fn update(p: *Player) void {
    const dpad = Fly.pad.toDPad().held(Fly.pre.toDPad());

    if (dpad.left) p.dir.x = -1;
    if (dpad.right) p.dir.x = 1;
    if (dpad.up) p.dir.y = -1;
    if (dpad.down) p.dir.y = 1;

    if (dpad.any()) {
        p.f = p.f * 0.99;
    }

    p.d = @intFromFloat(p.f);

    const target = p.pos.add(p.dir);

    if (Fly.SPACE.contains(target)) {
        p.pos = target;
    }
}

pub fn render(p: *Player) void {
    const sp = Fly.cam.screen(p.pos);

    ff.draw.Circle(sp.sub(.new(
        @divTrunc(p.d, 2),
        @divTrunc(p.d, 2),
    )), p.d, .{
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
