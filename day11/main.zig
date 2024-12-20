const std = @import("std");
const input = @embedFile("input.txt");

fn maybeSplit(d: usize) ?[2]usize {
    var temp = d;
    var digit_count: usize = 0;

    while (temp > 0) : (temp /= 10) {
        digit_count += 1;
    }

    if (digit_count % 2 != 0) {
        return null;
    }

    const divisor = std.math.pow(usize, 10, digit_count / 2);

    return [2]usize{ d / divisor, d % divisor };
}

fn doIt(part: usize, blinks: usize) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stones = std.AutoHashMap(usize, usize).init(allocator);
    defer stones.deinit();

    var numbers = std.mem.tokenizeScalar(u8, input, ' ');
    while (numbers.next()) |number| {
        try stones.put(try std.fmt.parseInt(usize, number, 10), 1);
    }

    for (0..blinks) |_| {
        var new_stones = std.AutoHashMap(usize, usize).init(allocator);

        var it = stones.iterator();
        while (it.next()) |entry| {
            const value = entry.key_ptr.*;
            const count = entry.value_ptr.*;

            if (value == 0) {
                try new_stones.put(1, (new_stones.get(1) orelse 0) + count);
            } else {
                const split = maybeSplit(value);
                if (split) |s| {
                    for (s) |v| {
                        try new_stones.put(v, (new_stones.get(v) orelse 0) + count);
                    }
                } else {
                    try new_stones.put(value * 2024, (new_stones.get(value * 2024) orelse 0) + count);
                }
            }
        }

        stones.deinit();
        stones = new_stones;
    }

    var total: usize = 0;
    var it = stones.valueIterator();
    while (it.next()) |count| {
        total += count.*;
    }

    std.debug.print("Part {d}: {d}\n", .{ part, total });
}

pub fn main() !void {
    try doIt(1, 25);
    try doIt(2, 75);
}
