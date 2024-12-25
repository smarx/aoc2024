const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var keys = std.ArrayList([5]u8).init(allocator);
    defer keys.deinit();

    var locks = std.ArrayList([5]u8).init(allocator);
    defer locks.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    while (true) {
        const top = lines.next() orelse break;
        if (top[0] == '#') {
            var lock: [5]u8 = [_]u8{ 0, 0, 0, 0, 0 };
            for (0..5) |_| {
                const row = lines.next() orelse break;
                for (row, 0..) |c, i| {
                    if (c == '#') {
                        lock[i] += 1;
                    }
                }
            }

            try locks.append(lock);
        } else {
            var key: [5]u8 = [_]u8{ 5, 5, 5, 5, 5 };
            for (0..5) |_| {
                const row = lines.next() orelse break;
                for (row, 0..) |c, i| {
                    if (c == '.') {
                        key[i] -= 1;
                    }
                }
            }

            try keys.append(key);
        }
        _ = lines.next() orelse break;
    }

    var count: usize = 0;
    for (locks.items) |lock| {
        for (keys.items) |key| {
            for (0..5) |i| {
                if (lock[i] + key[i] > 5) {
                    break;
                }
            } else {
                count += 1;
            }
        }
    }

    std.debug.print("Part 1: {}\n", .{count});
}
