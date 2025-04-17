const std = @import("std");
const math = std.math;

// END IMPORTS

fn convolveRGBA(src: []u32, out: []u32, line: []f32, coeff: *const [8]f32, width: i32, height: i32) void {
    // for guassian blur
    // takes src image and writes the blurred and transposed result into out
    var rgba: u32 = undefined;

    // rgba values are technically u8 but are stored as f32 to avoid casting
    var prev_src_r: f32 = undefined;
    var prev_src_g: f32 = undefined;
    var prev_src_b: f32 = undefined;
    var prev_src_a: f32 = undefined;
    
    var curr_src_r: f32 = undefined;
    var curr_src_g: f32 = undefined;
    var curr_src_b: f32 = undefined;
    var curr_src_a: f32 = undefined;

    var curr_out_r: f32 = undefined;
    var curr_out_g: f32 = undefined;
    var curr_out_b: f32 = undefined;
    var curr_out_a: f32 = undefined;
    
    var prev_out_r: f32 = undefined;
    var prev_out_g: f32 = undefined;
    var prev_out_b: f32 = undefined;
    var prev_out_a: f32 = undefined;
    
    var prev_prev_out_r: f32 = undefined;
    var prev_prev_out_g: f32 = undefined;
    var prev_prev_out_b: f32 = undefined;
    var prev_prev_out_a: f32 = undefined;

    var src_index: i32 = undefined;
    var out_index: i32 = undefined;
    var line_index: i32 = undefined;
    
    var coeff_a0: f32 = undefined;
    var coeff_a1: f32 = undefined;
    var coeff_b1: f32 = undefined;
    var coeff_b2: f32 = undefined;

    var i: i32 = undefined;
    var j: i32 = undefined;

    i = 0;
    while (i < height) {
        src_index = i * width;
        out_index = i;
        line_index = 0;

        // left to right
        rgba = src[@as(usize, @intCast(src_index))];

        prev_src_r = @as(f32, @floatFromInt(rgba & 0xff));
        prev_src_g = @as(f32, @floatFromInt((rgba >> 8) & 0xff));
        prev_src_b = @as(f32, @floatFromInt((rgba >> 16) & 0xff));
        prev_src_a = @as(f32, @floatFromInt((rgba >> 24) & 0xff));

        prev_prev_out_r = prev_src_r * coeff[6];
        prev_prev_out_g = prev_src_g * coeff[6];
        prev_prev_out_b = prev_src_b * coeff[6];
        prev_prev_out_a = prev_src_a * coeff[6];

        prev_out_r = prev_prev_out_r;
        prev_out_g = prev_prev_out_g;
        prev_out_b = prev_prev_out_b;
        prev_out_a = prev_prev_out_a;

        coeff_a0 = coeff[0];
        coeff_a1 = coeff[1];
        coeff_b1 = coeff[4];
        coeff_b2 = coeff[5];

        j = 0;
        while (j < width) {
            rgba = src[@as(usize, @intCast(src_index))];
            curr_src_r = @as(f32, @floatFromInt(rgba & 0xff));
            curr_src_g = @as(f32, @floatFromInt((rgba >> 8) & 0xff));
            curr_src_b = @as(f32, @floatFromInt((rgba >> 16) & 0xff));
            curr_src_a = @as(f32, @floatFromInt((rgba >> 24) & 0xff));

            curr_out_r = curr_src_r * coeff_a0 + prev_src_r * coeff_a1 + prev_out_r * coeff_b1 + prev_prev_out_r * coeff_b2;
            curr_out_g = curr_src_g * coeff_a0 + prev_src_g * coeff_a1 + prev_out_g * coeff_b1 + prev_prev_out_g * coeff_b2;
            curr_out_b = curr_src_b * coeff_a0 + prev_src_b * coeff_a1 + prev_out_b * coeff_b1 + prev_prev_out_b * coeff_b2;
            curr_out_a = curr_src_a * coeff_a0 + prev_src_a * coeff_a1 + prev_out_a * coeff_b1 + prev_prev_out_a * coeff_b2;

            prev_prev_out_r = prev_out_r;
            prev_prev_out_g = prev_out_g;
            prev_prev_out_b = prev_out_b;
            prev_prev_out_a = prev_out_a;

            prev_out_r = curr_out_r;
            prev_out_g = curr_out_g;
            prev_out_b = curr_out_b;
            prev_out_a = curr_out_a;

            prev_src_r = curr_src_r;
            prev_src_g = curr_src_g;
            prev_src_b = curr_src_b;
            prev_src_a = curr_src_a;

            line[@as(usize, @intCast(line_index))] = prev_out_r;
            line[@as(usize, @intCast((line_index + 1)))] = prev_out_g;
            line[@as(usize, @intCast((line_index + 2)))] = prev_out_b;
            line[@as(usize, @intCast((line_index + 3)))] = prev_out_a;
            line_index += 4;
            src_index += 1;
            j += 1;
        }

        src_index -= 1;
        line_index -= 4;
        out_index += height * (width - 1);

        // right to left
        rgba = src[@as(usize, @intCast(src_index))];

        prev_src_r = @as(f32, @floatFromInt(rgba & 0xff));
        prev_src_g = @as(f32, @floatFromInt((rgba >> 8) & 0xff));
        prev_src_b = @as(f32, @floatFromInt((rgba >> 16) & 0xff));
        prev_src_a = @as(f32, @floatFromInt((rgba >> 24) & 0xff));

        prev_prev_out_r = prev_src_r * coeff[7];
        prev_prev_out_g = prev_src_g * coeff[7];
        prev_prev_out_b = prev_src_b * coeff[7];
        prev_prev_out_a = prev_src_a * coeff[7];

        prev_out_r = prev_prev_out_r;
        prev_out_g = prev_prev_out_g;
        prev_out_b = prev_prev_out_b;
        prev_out_a = prev_prev_out_a;

        curr_src_r = prev_src_r;
        curr_src_g = prev_src_g;
        curr_src_b = prev_src_b;
        curr_src_a = prev_src_a;

        coeff_a0 = coeff[2];
        coeff_a1 = coeff[3];

        j = width - 1;
        while (j >= 0) {
            curr_out_r = curr_src_r * coeff_a0 + prev_src_r * coeff_a1 + prev_out_r * coeff_b1 + prev_prev_out_r * coeff_b2;
            curr_out_g = curr_src_g * coeff_a0 + prev_src_g * coeff_a1 + prev_out_g * coeff_b1 + prev_prev_out_g * coeff_b2;
            curr_out_b = curr_src_b * coeff_a0 + prev_src_b * coeff_a1 + prev_out_b * coeff_b1 + prev_prev_out_b * coeff_b2;
            curr_out_a = curr_src_a * coeff_a0 + prev_src_a * coeff_a1 + prev_out_a * coeff_b1 + prev_prev_out_a * coeff_b2;

            prev_prev_out_r = prev_out_r;
            prev_prev_out_g = prev_out_g;
            prev_prev_out_b = prev_out_b;
            prev_prev_out_a = prev_out_a;

            prev_out_r = curr_out_r;
            prev_out_g = curr_out_g;
            prev_out_b = curr_out_b;
            prev_out_a = curr_out_a;

            prev_src_r = curr_src_r;
            prev_src_g = curr_src_g;
            prev_src_b = curr_src_b;
            prev_src_a = curr_src_a;

            rgba = src[@as(usize, @intCast(src_index))];
            curr_src_r = @as(f32, @floatFromInt(rgba & 0xff));
            curr_src_g = @as(f32, @floatFromInt((rgba >> 8) & 0xff));
            curr_src_b = @as(f32, @floatFromInt((rgba >> 16) & 0xff));
            curr_src_a = @as(f32, @floatFromInt((rgba >> 24) & 0xff));

            rgba = ((@as(u32, @intFromFloat(line[@as(usize, @intCast(line_index      ))])) + @as(u32, @intFromFloat(prev_out_r))) << 0 ) +
                   ((@as(u32, @intFromFloat(line[@as(usize, @intCast((line_index + 1)))])) + @as(u32, @intFromFloat(prev_out_g))) << 8 ) +
                   ((@as(u32, @intFromFloat(line[@as(usize, @intCast((line_index + 2)))])) + @as(u32, @intFromFloat(prev_out_b))) << 16) +
                   ((@as(u32, @intFromFloat(line[@as(usize, @intCast((line_index + 3)))])) + @as(u32, @intFromFloat(prev_out_a))) << 24);

            out[@as(usize, @intCast(out_index))] = @as(u32, @intCast(rgba));

            src_index -= 1;
            line_index -= 4;
            out_index -= height;
            j -= 1;
        }
        
        i += 1;
    }
}

fn max(a: usize, b: usize) usize {
    if (a > b) {
        return a;
    }
    return b;
}

fn benchit() void {
    const w: usize = 800;
    const h: usize = 800;
    var src32: [w * h]u32 = undefined;
    var out: [w * h]u32 = undefined;
    var tmp_line: [max(w, h) * 4]f32 = undefined;

    const radius: f32 = 0.5;
    var sigma: f32 = radius;
    if (sigma < 0.5) {
        sigma = 0.5;
    }

    const a: f32 = math.exp(0.726 * 0.726) / sigma;
    const g1: f32 = math.exp(-a);
    const g2: f32 = math.exp(-2 * a);
    const k: f32 = (1 - g1) * (1 - g1) / (1 + 2 * a * g1 - g2);

    const a0: f32 = k;
    const a1: f32 = k * (a - 1) * g1;
    const a2: f32 = k * (a + 1) * g1;
    const a3: f32 = -k * g2;
    const b1: f32 = 2 * g1;
    const b2: f32 = -g2;
    const left_corner: f32 = (a0 + a1) / (1 - b1 - b2);
    const right_corner: f32 = (a2 + a3) / (1 - b1 - b2);

    var coeff: [8]f32 = .{
        a0,
        a1,
        a2,
        a3,
        b1,
        b2,
        left_corner,
        right_corner,
    };

    convolveRGBA(&src32, out[0..], tmp_line[0..], coeff[0..], w, h);
    convolveRGBA(out[0..], &src32, tmp_line[0..], coeff[0..], h, w);

    std.mem.doNotOptimizeAway(src32);
    std.mem.doNotOptimizeAway(out);
}
