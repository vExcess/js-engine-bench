const std = @import("std");

// END IMPORTS

var primeArray: std.ArrayList(u32) = undefined;

fn getPrimeFactors(integer: u32) *std.ArrayList(u32) {
    var isPrime: bool = false;
    var mutableInteger: u32 = integer;

    var i: u32 = 2;
    while (i <= mutableInteger) : (i += 1) {
        if (mutableInteger % i != 0) {
            continue;
        }

        var j: u32 = 2;
        while (j <= i / 2) : (j += 1) {
            isPrime = i % j != 0;
        }

        if (!isPrime) {
            continue;
        }

        mutableInteger /= i;
        primeArray.append(i) catch unreachable; // or handle the error appropriately
    }

    return &primeArray;
}

var maxFactors: usize = 0;
var maxFactorsNum: usize = 0;

pub fn benchit() void {
    primeArray = std.ArrayList(u32).init(std.heap.page_allocator);
    defer primeArray.deinit();
    
    maxFactors = 0;
    maxFactorsNum = 0;
    for (1..9450) |i| {
        const factors = getPrimeFactors(@as(u32, @intCast(i)));
        
        if (factors.items.len > maxFactors) {
            maxFactors = factors.items.len;
            maxFactorsNum = i;
        }

        primeArray.clearRetainingCapacity();
    }

    std.mem.doNotOptimizeAway(maxFactors);
    std.mem.doNotOptimizeAway(maxFactorsNum);
}

