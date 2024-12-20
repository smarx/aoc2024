const std = @import("std");
const input = @embedFile("input.txt");

fn get_rating(rows: *std.ArrayList(std.ArrayList(u8)), x: usize, y: usize, rating: usize) usize {
    if (rating == 9) {
        return 1;
    }

    const width = rows.items[0].items.len;
    const height = rows.items.len;

    var count: usize = 0;
    if (x > 0 and rows.items[y].items[x - 1] == rating + 1) {
        count += get_rating(rows, x - 1, y, rating + 1);
    }
    if (x < width - 1 and rows.items[y].items[x + 1] == rating + 1) {
        count += get_rating(rows, x + 1, y, rating + 1);
    }
    if (y > 0 and rows.items[y - 1].items[x] == rating + 1) {
        count += get_rating(rows, x, y - 1, rating + 1);
    }
    if (y < height - 1 and rows.items[y + 1].items[x] == rating + 1) {
        count += get_rating(rows, x, y + 1, rating + 1);
    }

    return count;
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

    var trailheads = std.ArrayList([2]usize).init(allocator);
    defer trailheads.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var cury: usize = 0;
    while (lines.next()) |line| {
        var row = std.ArrayList(u8).init(allocator);
        for (line, 0..) |c, x| {
            try row.append(c - '0');
            if (c == '0') {
                try trailheads.append([2]usize{ x, cury });
            }
        }
        try rows.append(row);
        cury += 1;
    }

    const width = rows.items[0].items.len;
    const height = rows.items.len;

    var total: usize = 0;

    for (trailheads.items) |trailhead| {
        var frontier = std.AutoHashMap([2]usize, void).init(allocator);
        defer frontier.deinit();

        try frontier.put(trailhead, {});
        for (1..10) |i| {
            var next = std.AutoHashMap([2]usize, void).init(allocator);
            var it = frontier.keyIterator();
            while (it.next()) |f| {
                const x = f[0];
                const y = f[1];

                if (x > 0 and rows.items[y].items[x - 1] == i) {
                    try next.put([2]usize{ x - 1, y }, {});
                }
                if (x < width - 1 and rows.items[y].items[x + 1] == i) {
                    try next.put([2]usize{ x + 1, y }, {});
                }
                if (y > 0 and rows.items[y - 1].items[x] == i) {
                    try next.put([2]usize{ x, y - 1 }, {});
                }
                if (y < height - 1 and rows.items[y + 1].items[x] == i) {
                    try next.put([2]usize{ x, y + 1 }, {});
                }
            }

            frontier.deinit();
            frontier = next;
        }

        total += frontier.count();
    }

    std.debug.print("Part 1: {}\n", .{total});

    var total_rating: usize = 0;
    for (trailheads.items) |trailhead| {
        total_rating += get_rating(&rows, trailhead[0], trailhead[1], 0);
    }

    std.debug.print("Part 2: {}\n", .{total_rating});
}
