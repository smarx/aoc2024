const std = @import("std");
const input = @embedFile("input.txt");

pub fn isSafe(readings: []i32) bool {
    const ascending = readings[1] > readings[0];

    for (0..readings.len - 1) |i| {
        if ((readings[i + 1] > readings[i]) != ascending) {
            return false;
        }
        const diff = @abs(readings[i + 1] - readings[i]);
        if (diff > 3 or diff == 0) {
            return false;
        }
    }

    return true;
}

pub fn part1() !void {
    var it = std.mem.tokenizeScalar(u8, input, '\n');
    var readings = std.ArrayList(i32).init(std.heap.page_allocator);

    var safe_count: usize = 0;

    while (it.next()) |line| {
        var line_iterator = std.mem.tokenizeScalar(u8, line, ' ');

        while (line_iterator.next()) |word| {
            const num = try std.fmt.parseInt(i32, word, 10);
            try readings.append(num);
        }

        if (isSafe(readings.items)) {
            safe_count += 1;
        }

        readings.clearRetainingCapacity();
    }

    std.debug.print("Part 1: {d}\n", .{safe_count});
}

pub fn part2() !void {
    var it = std.mem.tokenizeScalar(u8, input, '\n');

    var readings = std.ArrayList(i32).init(std.heap.page_allocator);

    var safe_count: usize = 0;

    while (it.next()) |line| {
        var line_iterator = std.mem.tokenizeScalar(u8, line, ' ');

        while (line_iterator.next()) |word| {
            const num = try std.fmt.parseInt(i32, word, 10);
            try readings.append(num);
        }

        if (isSafe(readings.items)) {
            safe_count += 1;
        } else {
            for (0..readings.items.len) |to_remove| {
                const removed = readings.orderedRemove(to_remove);

                if (isSafe(readings.items)) {
                    safe_count += 1;
                    break;
                }

                try readings.insert(to_remove, removed);
            }
        }

        readings.clearRetainingCapacity();
    }

    std.debug.print("Part 2: {d}\n", .{safe_count});
}

pub fn main() !void {
    try part1();
    try part2();
}
