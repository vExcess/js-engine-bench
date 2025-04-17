// modified from https://www.khanacademy.org/computer-programming/i/5919189559197696
// under MIT License

const std = @import("std");
const math = std.math;

// END IMPORTS

fn abs(x: f64) f64 {
    return if (x < 0.0) -x else x;
}

var pixels: [600 * 600 * 4]u8 = undefined;

fn benchit() void {
    const width: f64 = 600;
    const height: f64 = 600;
    const max_iter: i32 = 200;

    for (0..@as(i32, width)) |x| {
        for (0..@as(i32, height)) |y| {
            const a: f64 = 4.0 * @as(f64, @floatFromInt(x)) / width - 2.0;
            const b: f64 = 4.0 * @as(f64, @floatFromInt(y)) / height - 2.0;
            var iter: i32 = 0;
            const ca: f64 = a;
            const cb: f64 = b;
            var current_a: f64 = a;
            var current_b: f64 = b;

            while (iter < max_iter) {
                const aa: f64 = current_a * current_a - current_b * current_b;
                const bb: f64 = 2.0 * current_a * current_b;
                current_a = aa + ca;
                current_b = bb + cb;
                if (abs(current_a + current_b) > 16.0) {
                    break;
                }
                iter += 1;
            }

            var bright: f64 = @as(f64, @floatFromInt(iter)) / @as(f64, @floatFromInt(max_iter));
            bright = math.sqrt(bright) * 150.0;
            if (iter == max_iter) {
                bright = 255.0;
            }

            const p: usize = (@as(usize, @intCast(x)) + @as(usize, @intCast(y)) * 600) * 4;
            pixels[p + 0] = @as(u8, @intFromFloat(255.0 - bright));
            pixels[p + 1] = @as(u8, @intFromFloat(255.0 - bright));
            pixels[p + 2] = @as(u8, @intFromFloat(255.0 - bright));
            pixels[p + 3] = 255; // alpha
        }
    }

    std.mem.doNotOptimizeAway(pixels);
}
