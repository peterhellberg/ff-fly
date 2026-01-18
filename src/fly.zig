const ff = @import("ff");

const draw = ff.draw;

const Camera = @import("fly/Camera.zig");
const Cheats = @import("fly/Cheats.zig");
const Circle = @import("fly/Circle.zig");
const Enemy = @import("fly/Enemy.zig");
const Player = @import("fly/Player.zig");
const Random = @import("fly/Random.zig");
const Star = @import("fly/Star.zig");

pub const SIZE_SPACE = 6;
pub const SIZE_PLAYER = 20;
pub const SIZE_PLAYER_MAX = 45;
pub const SIZE_ENEMY_MAX = 45;
pub const NUM_ENEMIES = 128;
pub const NUM_STARS = 768;
pub const SPACE = ff.Rect.new(
    0,
    0,
    ff.width * SIZE_SPACE,
    ff.height * SIZE_SPACE,
);

pub var pad: ff.Pad = undefined;
pub var pre: ff.Pad = undefined;
pub var cam: Camera = .{};
pub var player: Player = .{};

var state: State = .Menu;

var menu: Menu = .{};
var init: Init = .{};
var game: Game = .{};
var over: Over = .{};

var buf: [1735]u8 = undefined;
var fff: ff.Font = undefined;

var btn: ff.Buttons = undefined;
var old: ff.Buttons = undefined;

var pal: ff.Palette = .{
    .black = 0x131313, //      black
    .dark_gray = 0x505050, //  dark gray
    .gray = 0x8D8D8D, //       gray
    .cyan = 0xA8A8A8, //       medium gray
    .light_gray = 0xCECECE, // light gray
    .white = 0xf2f0e5, //      white
    .light_blue = 0xA8A8A8, // gray
    .orange = 0xf7a41d, //     orange
    .dark_green = 0xC77C03, // dark orange
    .red = 0xb4202a, //        TODO: better enemy fill color
    .purple = 0x73172d, //     TODO: better enemy outline color
};

var frame: u32 = 0;

const State = enum {
    Menu,
    Init,
    Game,
    Over,

    fn update(s: State) void {
        frame += 1;

        const me = ff.getMe();
        {
            pre = pad;
            pad = ff.readPad(me).?;

            old = btn;
            btn = ff.readButtons(me);
        }

        switch (s) {
            .Menu => menu.update(),
            .Init => init.update(),
            .Game => game.update(),
            .Over => over.update(),
        }
    }

    fn render(s: State) void {
        ff.clearScreen(.black);

        if (cheats.tagName) {
            text(@tagName(s), .new(10, 10), .dark_blue);
        }

        switch (s) {
            .Menu => menu.render(),
            .Init => init.render(),
            .Game => game.render(),
            .Over => over.render(),
        }
    }
};

const Menu = struct {
    blink: bool = false,

    fn update(self: *Menu) void {
        if (@mod(frame, 12) == 0) self.blink = !self.blink;

        if (!btn.e and old.e) state = .Init;
        if (!btn.s and old.s) state = .Over;
    }

    fn render(_: *Menu) void {
        renderMenuFirefly();
    }

    inline fn renderMenuFirefly() void {
        renderStars();

        if (true) { // F
            const l = ff.Style{ .fill_color = if (menu.blink) .white else .yellow };
            const m = ff.Style{ .fill_color = if (menu.blink) .yellow else .orange };
            const d = ff.Style{ .fill_color = if (menu.blink) .orange else .dark_green };

            quad(75, 34, 75, 54, 89, 60, 89, 42, m);
            quad(48, 60, 45, 112, 63, 113, 65, 66, m);
            quad(73, 66, 72, 86, 87, 90, 87, 72, m);
            quad(75, 55, 49, 60, 68, 67, 89, 60, d);
            quad(73, 86, 47, 90, 65, 94, 85, 90, d);
            quad(45, 111, 29, 115, 47, 117, 63, 114, d);
            quad(47, 71, 47, 90, 72, 86, 72, 66, l);
            quad(29, 44, 76, 34, 75, 54, 28, 64, l);
            quad(29, 62, 26, 114, 44, 112, 48, 60, l);
        }

        if (true) { // L
            const l = ff.Style{ .fill_color = if (!menu.blink) .white else .yellow };
            const m = ff.Style{ .fill_color = if (!menu.blink) .yellow else .orange };
            const d = ff.Style{ .fill_color = if (!menu.blink) .orange else .dark_green };

            quad(140, 108, 153, 111, 83, 111, 83, 111, d);

            draw.tri(106, 30, 122, 38, 107, 85, m);
            draw.tri(122, 88, 122, 38, 107, 85, m);
            draw.tri(140, 83, 154, 89, 140, 107, m);
            draw.tri(154, 111, 154, 89, 140, 107, m);
            draw.tri(83, 33, 107, 29, 107, 85, l);
            draw.tri(83, 33, 81, 87, 107, 85, l);
            draw.tri(140, 83, 81, 87, 81, 111, l);
            draw.tri(140, 83, 140, 107, 81, 111, l);
        }

        if (true) { // Y
            const l = ff.Style{ .fill_color = if (!menu.blink) .white else .yellow };
            const m = ff.Style{ .fill_color = if (!menu.blink) .yellow else .orange };
            const d = ff.Style{ .fill_color = if (!menu.blink) .orange else .dark_green };

            quad(218, 6, 188, 74, 199, 79, 225, 20, d);
            quad(188, 105, 159, 107, 171, 109, 198, 107, d);
            quad(188, 74, 189, 104, 199, 107, 199, 80, m);
            quad(156, 19, 171, 42, 177, 43, 168, 29, m);
            quad(156, 77, 156, 107, 189, 104, 188, 74, l);
            draw.tri(185, 12, 156, 77, 188, 74, l);
            draw.tri(129, 24, 157, 77, 156, 19, l);
            draw.tri(156, 19, 171, 44, 156, 77, l);
            draw.tri(218, 6, 185, 12, 189, 73, l);
        }

        text("PRESS (E) TO START GAME!", .new(50, 140), .white);
    }

    fn quad(x1: i32, y1: i32, x2: i32, y2: i32, x3: i32, y3: i32, x4: i32, y4: i32, s: ff.Style) void {
        draw.tri(x1, y1, x2, y2, x3, y3, s);
        draw.tri(x1, y1, x3, y3, x4, y4, s);
    }
};

var enemies: [NUM_ENEMIES]Enemy = [_]Enemy{.{}} ** NUM_ENEMIES;

const Init = struct {
    fn update(_: *Init) void {
        player = .{};

        for (&enemies) |*e| {
            e.spawn(SPACE);
        }

        state = .Game;
    }

    fn render(_: *Init) void {}
};

const Game = struct {
    fn update(_: *Game) void {
        player.update();

        cam.center(player.pos);
        cam.clamp(SPACE);

        for (&enemies) |*enemy| {
            enemy.update();
        }

        collisions();

        if (player.d < 3) state = .Over;
        if (!btn.n and old.n) state = .Menu;
        if (!btn.s and old.s) state = .Over;
    }

    inline fn collisions() void {
        enemyCollisions();
        playerCollision();
    }

    fn enemyCollisions() void {
        for (&enemies, 0..) |*a, i| {
            for (enemies[i + 1 ..]) |*b| {
                const delta = b.vec - a.vec;
                const dist_sq = vecLenSq(delta);

                const min_dist: f32 = @as(f32, @floatFromInt(a.d + b.d)) * 0.5;
                const min_dist_sq = min_dist * min_dist;

                if (dist_sq == 0 or dist_sq >= min_dist_sq)
                    continue;

                const distance = @sqrt(dist_sq);
                const separation = (min_dist - distance) * 0.5;
                const direction = delta * @as(ff.Vec, @splat(1.0 / distance));
                const correction = direction * @as(ff.Vec, @splat(separation));

                a.vec -= correction;
                b.vec += correction;

                // Update integer positions for rendering
                a.pos = ff.Point.from_vec(a.vec);
                b.pos = ff.Point.from_vec(b.vec);

                // Growth/shrink logic: bigger enemy grows, smaller shrinks
                if (a.d >= b.d) {
                    if (a.d < SIZE_ENEMY_MAX) a.f += 0.05; // only grow if below max
                    b.f -= 0.05;
                } else {
                    if (b.d < SIZE_ENEMY_MAX) b.f += 0.05;
                    a.f -= 0.05;
                }

                a.d = @intFromFloat(a.f);
                b.d = @intFromFloat(b.f);
            }
        }
    }

    fn enemyCollisionsX() void {
        for (&enemies, 0..) |*a, i| {
            for (enemies[i + 1 ..]) |*b| {
                const delta = b.vec - a.vec;
                const dist_sq = vecLenSq(delta);

                const min_dist: f32 = @as(f32, @floatFromInt(a.d + b.d)) * 0.5;
                const min_dist_sq = min_dist * min_dist;

                if (dist_sq == 0 or dist_sq >= min_dist_sq)
                    continue;

                const distance = @sqrt(dist_sq);
                const separation = (min_dist - distance) * 0.5;
                const direction = delta * @as(ff.Vec, @splat(1.0 / distance));
                const correction = direction * @as(ff.Vec, @splat(separation));

                // Push enemies apart
                a.vec -= correction;
                b.vec += correction;

                // Update integer positions for rendering
                a.pos = ff.Point.new(
                    @as(i32, @intFromFloat(@round(a.vec[0]))),
                    @as(i32, @intFromFloat(@round(a.vec[1]))),
                );
                b.pos = ff.Point.new(
                    @as(i32, @intFromFloat(@round(b.vec[0]))),
                    @as(i32, @intFromFloat(@round(b.vec[1]))),
                );

                // --- Grow/shrink logic ---
                if (a.d > b.d) {
                    a.f += 0.05; // bigger grows
                    b.f -= 0.05; // smaller shrinks
                } else if (b.d > a.d) {
                    b.f += 0.05;
                    a.f -= 0.05;
                }

                // Clamp sizes so nothing goes negative
                a.d = @intFromFloat(@max(a.f, 1.0));
                b.d = @intFromFloat(@max(b.f, 1.0));
            }
        }
    }

    inline fn vecLenSq(v: ff.Vec) f32 {
        return v[0] * v[0] + v[1] * v[1];
    }

    fn playerCollision() void {
        const pc = player.circle();

        for (&enemies) |*enemy| {
            const ec = enemy.circle();

            if (ec.intersect(pc)) {
                if (pc.contains(ec)) {
                    enemy.spawn(SPACE);
                }

                if (ec.contains(pc)) {
                    state = .Over;
                }

                if (enemy.d < player.d) {
                    player.f = @min(player.f + 0.1, SIZE_PLAYER_MAX);
                    enemy.f -= 0.2;
                } else {
                    player.f -= 0.6;
                    if (player.f < 0) state = .Over;
                }

                player.d = @intFromFloat(player.f);
                enemy.d = @intFromFloat(enemy.f);
            }
        }
    }

    fn playerCollisionX() void {
        const pc = player.circle();

        for (&enemies) |*enemy| {
            const ec = enemy.circle();

            if (ec.intersect(pc)) {
                if (pc.contains(ec)) {
                    enemy.spawn(SPACE);
                }

                if (ec.contains(pc)) state = .Over;

                if (enemy.d < player.d) {
                    player.f += 0.1;
                    enemy.f -= 0.2;
                } else {
                    player.f -= 0.6;
                    if (player.f < 0) state = .Over;
                }
            }
        }
    }

    fn render(_: *Game) void {
        renderStars();

        if (cheats.preyLines) {
            for (enemies) |enemy| {
                enemy.line();
            }
        }

        for (enemies) |enemy| {
            enemy.render();
        }

        player.render();
    }
};

const Over = struct {
    fn update(_: *Over) void {
        if (!btn.e and old.e) state = .Init;
        if (!btn.n and old.n) state = .Menu;
    }

    fn render(_: *Over) void {
        renderStars();

        const x = 46;
        const s = sine(frame);

        text(" _____ _____ _____ _____ ", .{ .x = x, .y = 25 - s }, .light_gray);
        text("|   __|  _  |     |   __|", .{ .x = x, .y = 35 - s }, .cyan);
        text("|  |  |     | | | |   __|", .{ .x = x, .y = 45 - s }, .gray);
        text("|_____|__|__|_|_|_|_____|", .{ .x = x, .y = 55 - s }, .dark_gray);
        text(" _____ _____ _____ _____ ", .{ .x = x - 1, .y = 25 - s }, .cyan);
        text("|   __|  _  |     |   __|", .{ .x = x - 1, .y = 35 - s }, .light_gray);
        text("|  |  |     | | | |   __|", .{ .x = x - 1, .y = 45 - s }, .cyan);
        text("|_____|__|__|_|_|_|_____|", .{ .x = x - 1, .y = 55 - s }, .gray);

        text(" _____ __ __ _____ _____ ", .{ .x = x, .y = 75 + s }, .light_gray);
        text("|     |  |  |   __| __  |", .{ .x = x, .y = 85 + s }, .cyan);
        text("|  |  |  |  |   __|    -|", .{ .x = x, .y = 95 + s }, .dark_gray);
        text("|_____|\\___/|_____|__|__|", .{ .x = x, .y = 105 + s }, .dark_green);
        text(" _____ __ __ _____ _____ ", .{ .x = x - 1, .y = 75 + s }, .light_gray);
        text("|     |  |  |   __| __  |", .{ .x = x - 1, .y = 85 + s }, .light_gray);
        text("|  |  |  |  |   __|    -|", .{ .x = x - 1, .y = 95 + s }, .cyan);
        text("|_____|\\___/|_____|__|__|", .{ .x = x - 1, .y = 105 + s }, .orange);

        text("PRESS (E) TO PLAY AGAIN!", .{ .x = 50, .y = 140 }, .white);
    }
};

var stars: [NUM_STARS]Star = [_]Star{.{}} ** NUM_STARS;

fn renderStars() void {
    for (stars) |star| {
        star.render();
    }
}

pub fn text(t: ff.String, p: ff.Point, c: ff.Color) void {
    draw.Text(t, fff, p, c);
}

fn sine(f: u32) i32 {
    return sine256[@as(usize, @intCast(f & 0xFF))];
}

pub const sine256 = [256]i8{
    0,  0,  0,  1,  1,  1,  1,  1,  2,  2,  2,  2,  2,  3,  3,  3,
    3,  3,  3,  4,  4,  4,  4,  4,  4,  5,  5,  5,  5,  5,  5,  6,
    6,  6,  6,  6,  6,  6,  6,  7,  7,  7,  7,  7,  7,  7,  7,  7,
    7,  7,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,
    8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  7,
    7,  7,  7,  7,  7,  7,  7,  7,  7,  7,  6,  6,  6,  6,  6,  6,
    6,  6,  5,  5,  5,  5,  5,  5,  4,  4,  4,  4,  4,  4,  3,  3,
    3,  3,  3,  3,  2,  2,  2,  2,  2,  1,  1,  1,  1,  1,  0,  0,

    0,  0,  0,  -1, -1, -1, -1, -1, -2, -2, -2, -2, -2, -3, -3, -3,
    -3, -3, -3, -4, -4, -4, -4, -4, -4, -5, -5, -5, -5, -5, -5, -6,
    -6, -6, -6, -6, -6, -6, -6, -7, -7, -7, -7, -7, -7, -7, -7, -7,
    -7, -7, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8,
    -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -8, -7,
    -7, -7, -7, -7, -7, -7, -7, -7, -7, -7, -6, -6, -6, -6, -6, -6,
    -6, -6, -5, -5, -5, -5, -5, -5, -4, -4, -4, -4, -4, -4, -3, -3,
    -3, -3, -3, -3, -2, -2, -2, -2, -2, -1, -1, -1, -1, -1, 0,  0,
};

var cheats: Cheats = .{};

pub export fn cheat(cmd: i32, val: i32) i32 {
    return cheats.apply(cmd, val);
}

pub export fn boot() void {
    pal.set();

    fff = ff.loadFile("font", buf[0..]);

    for (&stars) |*s| {
        s.pos = Random.pos(SPACE);
        s.c = Random.starColor();
    }
}

pub export fn update() void {
    state.update();
}

pub export fn render() void {
    state.render();
}
