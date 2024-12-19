const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var antennas = std.AutoHashMap(u8, std.ArrayList([2]usize)).init(allocator);
    defer {
        var iter = antennas.valueIterator();
        while (iter.next()) |value| {
            value.deinit();
        }
        antennas.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var height: usize = 0;
    var width: usize = 0;

    var x: usize = 0;
    var y: usize = 0;
    while (lines.next()) |line| {
        if (y > height) {
            height = y;
        }
        x = 0;
        for (line) |c| {
            if (x > width) {
                width = x;
            }

            if (c == '.') {
                x += 1;
                continue;
            }

            if (antennas.getPtr(c)) |list| {
                try list.append([2]usize{ x, y });
            } else {
                var list = std.ArrayList([2]usize).init(allocator);
                try list.append([2]usize{ x, y });
                try antennas.put(c, list);
            }
            x += 1;
        }
        y += 1;
    }

    width += 1;
    height += 1;
    {
        var antinodes = std.AutoHashMap([2]usize, void).init(allocator);
        defer antinodes.deinit();

        var iter = antennas.iterator();
        while (iter.next()) |entry| {
            const locations = entry.value_ptr;
            for (locations.items, 0..) |first, i| {
                for (locations.items[i + 1 ..]) |second| {
                    const x1: i32 = @intCast(first[0]);
                    const y1: i32 = @intCast(first[1]);
                    const x2: i32 = @intCast(second[0]);
                    const y2: i32 = @intCast(second[1]);

                    const a1 = [2]i32{ x1 * 2 - x2, y1 * 2 - y2 };
                    const a2 = [2]i32{ x2 * 2 - x1, y2 * 2 - y1 };

                    if (a1[0] >= 0 and a1[0] < width and a1[1] >= 0 and a1[1] < height) {
                        try antinodes.put([2]usize{ @intCast(a1[0]), @intCast(a1[1]) }, void{});
                    }

                    if (a2[0] >= 0 and a2[0] < width and a2[1] >= 0 and a2[1] < height) {
                        try antinodes.put([2]usize{ @intCast(a2[0]), @intCast(a2[1]) }, void{});
                    }
                }
            }
        }

        std.debug.print("Part 1: {}\n", .{antinodes.count()});
    }

    {
        var antinodes = std.AutoHashMap([2]usize, void).init(allocator);
        defer antinodes.deinit();

        var iter = antennas.iterator();
        while (iter.next()) |entry| {
            const locations = entry.value_ptr;
            for (locations.items, 0..) |first, i| {
                for (locations.items[i + 1 ..]) |second| {
                    const x1: i32 = @intCast(first[0]);
                    const y1: i32 = @intCast(first[1]);
                    const x2: i32 = @intCast(second[0]);
                    const y2: i32 = @intCast(second[1]);

                    const deltax = x2 - x1;
                    const deltay = y2 - y1;

                    var curx = x1;
                    var cury = y1;

                    while (curx >= 0 and curx < width and cury >= 0 and cury < height) {
                        curx -= deltax;
                        cury -= deltay;
                    }

                    curx += deltax;
                    cury += deltay;

                    while (curx >= 0 and curx < width and cury >= 0 and cury < height) {
                        try antinodes.put([2]usize{ @intCast(curx), @intCast(cury) }, void{});
                        curx += deltax;
                        cury += deltay;
                    }
                }
            }
        }

        std.debug.print("Part 2: {}\n", .{antinodes.count()});
    }
}
