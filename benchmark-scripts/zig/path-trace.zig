// modified from https://www.khanacademy.org/computer-programming/new-webpage/5620563683229696
// under MIT License

const std = @import("std");
const math = std.math;

// END IMPORTS

var prng = std.Random.DefaultPrng.init(0);
var rand = prng.random(); // Initialize PRNG with a seed

fn normalize(v: [3]f64) [3]f64 {
    const lv: f64 = 1.0 / math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    return .{ v[0] * lv, v[1] * lv, v[2] * lv };
}

fn reflect(v: [3]f64, n: [3]f64) [3]f64 {
    const dn: f64 = v[0] * n[0] + v[1] * n[1] + v[2] * n[2];
    return .{ v[0] - 2 * n[0] * dn, v[1] - 2 * n[1] * dn, v[2] - 2 * n[2] * dn };
}

fn uniformVec() [3]f64 {
    var v: [3]f64 = .{ random(-1.0, 1.0), random(-1.0, 1.0), random(-1.0, 1.0) };
    while (true) {
        if (math.sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]) < 1.0) {
            return normalize(v);
        }
        v = .{ random(-1.0, 1.0), random(-1.0, 1.0), random(-1.0, 1.0) };
    }
}

fn random(mi: f64, ma: f64) f64 {
    return mi + (rand.float(f64) * (ma - mi));
}

fn lerp(value1: f64, value2: f64, amt: f64) f64 {
    return ((value2 - value1) * amt) + value1;
}

const sky: [3]f64 = .{ 0.7, 0.9, 1.0 };

const TraceResult = struct {
    h: bool,
    currT: f64,
    n: [3]f64,
    mat: ?[6]f64,
};

fn traceSphere(o: [3]f64, d: [3]f64, s: [4]f64, mat: [6]f64) TraceResult {
    const oc: [3]f64 = .{ o[0] - s[0], o[1] - s[1], o[2] - s[2] };
    const a: f64 = d[0] * d[0] + d[1] * d[1] + d[2] * d[2];
    const b: f64 = 2 * (d[0] * oc[0] + d[1] * oc[1] + d[2] * oc[2]);
    const c: f64 = (oc[0] * oc[0] + oc[1] * oc[1] + oc[2] * oc[2]) - s[3] * s[3];
    const disc: f64 = b * b - 4 * a * c;
    const currT: f64 = (-b - math.sqrt(disc)) / (2 * a);

    const h: bool = disc > 0 and currT >= 0;

    if (h) {
        return TraceResult{
            .h = h,
            .currT = currT,
            .n = .{
                (o[0] + d[0] * currT - s[0]) / s[3],
                (o[1] + d[1] * currT - s[1]) / s[3],
                (o[2] + d[2] * currT - s[2]) / s[3],
            },
            .mat = mat,
        };
    } else {
        return TraceResult{
            .h = h,
            .currT = 100000.0,
            .n = .{ 0.0, 0.0, 0.0 },
            .mat = null,
        };
    }
}

fn traceScene(o: [3]f64, d: [3]f64, s: [][4]f64, mats: [][6]f64) TraceResult {
    var initT: f64 = 10000000.0;
    var currMat: ?[6]f64 = null;
    var n: [3]f64 = .{ 0.0, 0.0, 0.0 };
    var h: bool = false;

    for (0..s.len) |i| {
        if (i % 2 == 1) continue;
        const hit: TraceResult = traceSphere(o, d, s[i], mats[i / 2]);
        if (hit.h and hit.currT >= 0 and hit.currT < initT) {
            h = true;
            initT = hit.currT;
            n = hit.n;
            currMat = hit.mat;
        }
    }
    return TraceResult{
        .h = h,
        .currT = initT,
        .n = n,
        .mat = currMat,
    };
}

fn pathTrace(o_: [3]f64, d_: [3]f64, s: [][4]f64, mats: [][6]f64) [3]f64 {
    var o = o_;
    var d = d_;
    var col: [3]f64 = .{ 1.0, 1.0, 1.0 };

    var i: i32 = 0; while (i < 12) : (i += 1) {
        const hit: TraceResult = traceScene(o, d, s, mats);
        if (hit.h) {
            const isSpec: bool = hit.mat.?[5] > random(0.0, 1.0);

            col[0] *= lerp(hit.mat.?[3] * hit.mat.?[0], 1.0, @as(f64, (if (isSpec) 1.0 else 0.0)));
            col[1] *= lerp(hit.mat.?[3] * hit.mat.?[1], 1.0, @as(f64, (if (isSpec) 1.0 else 0.0)));
            col[2] *= lerp(hit.mat.?[3] * hit.mat.?[2], 1.0, @as(f64, (if (isSpec) 1.0 else 0.0)));

            if (hit.mat.?[3] > 1.0) break;

            o = .{
                o[0] + d[0] * hit.currT,
                o[1] + d[1] * hit.currT,
                o[2] + d[2] * hit.currT,
            };

            var dd: [3]f64 = uniformVec();

            dd = normalize(.{
                dd[0] + hit.n[0],
                dd[1] + hit.n[1],
                dd[2] + hit.n[2],
            });

            const rd: [3]f64 = normalize(reflect(d, hit.n));

            d = .{
                lerp(dd[0], rd[0], hit.mat.?[4] * @as(f64, (if (isSpec) 1.0 else 0.0))),
                lerp(dd[1], rd[1], hit.mat.?[4] * @as(f64, (if (isSpec) 1.0 else 0.0))),
                lerp(dd[2], rd[2], hit.mat.?[4] * @as(f64, (if (isSpec) 1.0 else 0.0))),
            };
        } else {
            if (i >= 1) {
                col[0] *= sky[0] * 2.0;
                col[1] *= sky[1] * 2.0;
                col[2] *= sky[2] * 2.0;
            } else {
                col[0] *= sky[0];
                col[1] *= sky[1];
                col[2] *= sky[2];
            }
            break;
        }
    }
    return col;
}

var its: f64 = 1.0;

var colorBuffer: [400 * 400 * 4]f32 = [_]f32{0} ** (400 * 400 * 4);

var scene: [5][4]f64 = [_][4]f64{
    [_]f64{ -1.5, 0.5, 5.0, 0.5 },
    [_]f64{ 1.0, -1.0, 4.0, 0.35 },
    [_]f64{ 0.0, 0.5, 5.0, 0.5 },
    [_]f64{ 1.5, 0.5, 5.0, 0.5 },
    [_]f64{ 0.0, 10001.0, 5.0, 10000.0 },
};

var materials: [5][6]f64 = [_][6]f64{
    [_]f64{ 1.0, 0.0, 0.0, 0.5, 1.0, 0.01 },
    [_]f64{ 1.0, 1.0, 1.0, 20.0, 0.0, 0.0 },
    [_]f64{ 0.0, 1.0, 0.0, 0.5, 0.0, 0.0 },
    [_]f64{ 0.0, 0.0, 1.0, 0.5, 1.0, 0.3 },
    [_]f64{ 1.0, 1.0, 1.0, 0.5, 0.9, 0.1 },
};

const WIDTH: usize = 210;
const HEIGHT: usize = 210;

var id: [WIDTH * HEIGHT * 4]u8 = [_]u8{0} ** (WIDTH * HEIGHT * 4);

fn min(a: f64, b: f64) f64 {
    if (a < b) {
        return a;
    }
    return b;
}

pub fn benchit() void {
    for (0..WIDTH) |i| {
        for (0..HEIGHT) |j| {
            const u: f64 = (@as(f64, @floatFromInt(i)) + random(-0.5, 0.5) - (@as(f64, @floatFromInt(WIDTH)) / 2.0)) / @as(f64, @floatFromInt(WIDTH));
            const v: f64 = (@as(f64, @floatFromInt(j)) + random(-0.5, 0.5) - (@as(f64, @floatFromInt(HEIGHT)) / 2.0)) / @as(f64, @floatFromInt(HEIGHT));
            const ci: usize = (i + j * WIDTH) * 4;

            const o: [3]f64 = .{ 0.0, 0.0, 0.0 };
            const d: [3]f64 = normalize(.{ u, v, 1.0 });
            const col: [3]f64 = pathTrace(o, d, &scene, &materials);

            colorBuffer[ci] = @as(f32, @floatCast(lerp(colorBuffer[ci], col[0], 1.0 / its)));
            colorBuffer[ci + 1] = @as(f32, @floatCast(lerp(colorBuffer[ci + 1], col[1], 1.0 / its)));
            colorBuffer[ci + 2] = @as(f32, @floatCast(lerp(colorBuffer[ci + 2], col[2], 1.0 / its)));

            id[ci]     = @as(u8, @intFromFloat(min(255, math.pow(f64, @as(f64, @floatCast(colorBuffer[ci])), 1.0 / 2.2) * 255.0)));
            id[ci + 1] = @as(u8, @intFromFloat(min(255, math.pow(f64, @as(f64, @floatCast(colorBuffer[ci + 1])), 1.0 / 2.2) * 255.0)));
            id[ci + 2] = @as(u8, @intFromFloat(min(255, math.pow(f64, @as(f64, @floatCast(colorBuffer[ci + 2])), 1.0 / 2.2) * 255.0)));
            id[ci + 3] = 255;
        }
    }
    its += 1.0;
    std.mem.doNotOptimizeAway(its);
    std.mem.doNotOptimizeAway(colorBuffer);
}
