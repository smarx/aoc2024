const std = @import("std");
const input = @embedFile("input.txt");

pub fn part1(rows: *std.ArrayList(std.ArrayList(u8))) !void {
    const directions = [8][2]i8{ [2]i8{ 1, 1 }, [2]i8{ -1, -1 }, [2]i8{ 1, -1 }, [2]i8{ -1, 1 }, [2]i8{ 0, 1 }, [2]i8{ 0, -1 }, [2]i8{ 1, 0 }, [2]i8{ -1, 0 } };

    const target = "XMAS";

    const height = rows.items.len;
    const width = rows.items[0].items.len;

    var count: usize = 0;
    for (0..width) |x| {
        for (0..height) |y| {
            for (directions) |dir| {
                var pos = [2]i32{ @intCast(x), @intCast(y) };
                for (target) |c| {
                    if (pos[0] < 0 or pos[0] >= width) {
                        break;
                    }
                    if (pos[1] < 0 or pos[1] >= height) {
                        break;
                    }
                    if (rows.items[@intCast(pos[1])].items[@intCast(pos[0])] != c) {
                        break;
                    }

                    pos[0] += dir[0];
                    pos[1] += dir[1];
                } else {
                    count += 1;
                }
            }
        }
    }
    std.debug.print("Part 1: {d}\n", .{count});
}

pub fn part2(rows: *std.ArrayList(std.ArrayList(u8))) !void {
    const height = rows.items.len;
    const width = rows.items[0].items.len;

    var count: usize = 0;
    for (1..width - 1) |x| {
        for (1..height - 1) |y| {
            if (rows.items[y].items[x] != 'A') {
                continue;
            }
            if (((rows.items[y - 1].items[x - 1] == 'M' and rows.items[y + 1].items[x + 1] == 'S') or
                (rows.items[y - 1].items[x - 1] == 'S' and rows.items[y + 1].items[x + 1] == 'M')) and ((rows.items[y - 1].items[x + 1] == 'M' and rows.items[y + 1].items[x - 1] == 'S') or
                (rows.items[y - 1].items[x + 1] == 'S' and rows.items[y + 1].items[x - 1] == 'M')))
            {
                count += 1;
            }
        }
    }

    std.debug.print("Part 2: {d}\n", .{count});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var rows = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer {
        for (rows.items) |row| {
            row.deinit();
        }
        rows.deinit();
    }

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        var row = std.ArrayList(u8).init(allocator);
        for (line) |c| {
            try row.append(c);
        }
        try rows.append(row);
    }

    try part1(&rows);
    try part2(&rows);
}
