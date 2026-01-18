const Cheats = @This();

tagName: bool = false,
preyLines: bool = false,

pub fn apply(self: *Cheats, cmd: i32, val: i32) i32 {
    if (cmd == 1 and val == 42) {
        self.preyLines = !self.preyLines;

        return 0;
    }

    if (cmd == 2 and val == 42) {
        self.tagName = !self.tagName;

        return 0;
    }

    return -1;
}
