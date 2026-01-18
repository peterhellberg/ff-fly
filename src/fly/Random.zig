const ff = @import("ff");

pub inline fn mod(comptime T: type, d: T) T {
    return @mod(@as(T, @intCast(ff.getRandom())), d);
}

pub inline fn pos(space: ff.Rect) ff.Point {
    const r: u32 = ff.getRandom();

    return .{
        .x = @mod(@as(i32, @intCast(r & 0xFFFF)), space.size.width),
        .y = @mod(@as(i32, @intCast(r >> 16)), space.size.height),
    };
}

pub inline fn starColor() ff.Color {
    return if ((ff.getRandom() & 1) == 0) .light_gray else .dark_gray;
}
