const ff = @import("ff");

const Camera = @import("Camera.zig");

const Fly = @import("../main.zig");

const Star = @This();

pos: ff.Point = .{},
c: ff.Color = .white,

pub fn render(star: *const Star) void {
    if (Fly.cam.sees(star.pos)) {
        ff.draw.Point(Fly.cam.screen(star.pos), star.c);
    }
}
