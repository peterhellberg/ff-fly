const ff = @import("ff");

const Sound = @This();

gains: [4]ff.audio.Gain = undefined,
sines: [4]ff.audio.Sine = undefined,
index: usize = 0,

queue: [4]Sine = undefined,
queue_len: usize = 0,
elapsed_ms: u32 = 0,

pub fn init() Sound {
    var s: Sound = undefined;
    var i: usize = 0;

    while (i < s.sines.len) : (i += 1) {
        s.gains[i] = ff.audio.out.node.addGain(0.0);
        s.sines[i] = s.gains[i].node.addSine(.hz(0.0), 0.0);
    }

    return s;
}

pub fn sine(self: *Sound, start: ff.audio.Freq, end: ff.audio.Freq, duration_ms: u32, amplitude: f32, gap_ms: u32) void {
    if (self.queue_len >= self.queue.len) return;

    var start_time: u32 = self.elapsed_ms;

    if (self.queue_len > 0) {
        const last = self.queue[self.queue_len - 1];
        start_time = last.start_ms + last.duration_ms + gap_ms;
    }

    const total_duration: u32 = duration_ms;

    self.queue[self.queue_len] = .{
        .start_ms = start_time,
        .duration_ms = total_duration,
        .start_freq = start,
        .end_freq = end,
        .amplitude = amplitude,
        .started = false,
    };

    self.queue_len += 1;
}

pub fn tick(self: *Sound, delta_ms: u32) void {
    self.elapsed_ms += delta_ms;

    var i: usize = 0;

    while (i < self.queue_len) : (i += 1) {
        var sound = self.queue[i];

        if (!sound.started and self.elapsed_ms >= sound.start_ms) {
            const s = &self.sines[self.index];
            const g = &self.gains[self.index];

            self.index = (self.index + 1) % self.sines.len;

            const main_duration_ms: u32 = sound.duration_ms;

            s.modulate(.{
                .linear = .{
                    .start = sound.start_freq.h,
                    .end = sound.end_freq.h,
                    .start_at = .zero,
                    .end_at = .ms(main_duration_ms),
                },
            });

            g.modulate(.{
                .linear = .{
                    .start = sound.amplitude,
                    .end = 0.0,
                    .start_at = .zero,
                    .end_at = .ms(sound.duration_ms),
                },
            });

            sound.started = true;

            self.queue[i] = sound;
        } else if (sound.started and self.elapsed_ms >= sound.start_ms + sound.duration_ms) {
            self.queue_len -= 1;
            if (i != self.queue_len) self.queue[i] = self.queue[self.queue_len];
            i -= 1;
        }
    }
}

const Sine = struct {
    start_ms: u32,
    duration_ms: u32,
    start_freq: ff.audio.Freq,
    end_freq: ff.audio.Freq,
    amplitude: f32,
    started: bool = false,
};
