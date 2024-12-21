const std = @import("std");
const input = @embedFile("input.txt");

const width = 71; // 7;
const height = 71; // 7;
const how_many = 1024; // 12;

fn part1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var bytes = std.AutoHashMap([2]u8, void).init(allocator);
    defer bytes.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var count: usize = 0;
    while (lines.next()) |line| {
        var split = std.mem.tokenizeScalar(u8, line, ',');

        const x = try std.fmt.parseInt(u8, split.next() orelse break, 10);
        const y = try std.fmt.parseInt(u8, split.next() orelse break, 10);

        try bytes.put([_]u8{ x, y }, {});

        count += 1;
        if (count == how_many) {
            break;
        }
    }

    var frontier = std.ArrayList([2]u8).init(allocator);
    defer frontier.deinit();

    try frontier.append([_]u8{ 0, 0 });

    var seen = std.AutoHashMap([2]u8, void).init(allocator);
    defer seen.deinit();

    try seen.put([_]u8{ 0, 0 }, {});

    var steps: usize = 0;
    main: while (true) {
        var new_frontier = std.ArrayList([2]u8).init(allocator);
        for (frontier.items) |pos| {
            const x = pos[0];
            const y = pos[1];

            if (x == width - 1 and y == height - 1) {
                break :main;
            }

            if (x > 0) {
                const candidate = [_]u8{ x - 1, y };
                if (!bytes.contains(candidate) and !seen.contains(candidate)) {
                    try seen.put(candidate, {});
                    try new_frontier.append(candidate);
                }
            }

            if (x < width - 1) {
                const candidate = [_]u8{ x + 1, y };
                if (!bytes.contains(candidate) and !seen.contains(candidate)) {
                    try seen.put(candidate, {});
                    try new_frontier.append(candidate);
                }
            }

            if (y > 0) {
                const candidate = [_]u8{ x, y - 1 };
                if (!bytes.contains(candidate) and !seen.contains(candidate)) {
                    try seen.put(candidate, {});
                    try new_frontier.append(candidate);
                }
            }

            if (y < height - 1) {
                const candidate = [_]u8{ x, y + 1 };
                if (!bytes.contains(candidate) and !seen.contains(candidate)) {
                    try seen.put(candidate, {});
                    try new_frontier.append(candidate);
                }
            }
        }
        steps += 1;
        frontier.deinit();
        frontier = new_frontier;
    }

    std.debug.print("Part 1: {}\n", .{steps});
}

fn part2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var bytes_in_order = std.ArrayList([2]u8).init(allocator);
    defer bytes_in_order.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var split = std.mem.tokenizeScalar(u8, line, ',');

        const x = try std.fmt.parseInt(u8, split.next() orelse break, 10);
        const y = try std.fmt.parseInt(u8, split.next() orelse break, 10);

        try bytes_in_order.append([_]u8{ x, y });
    }

    var bytes = std.AutoHashMap([2]u8, void).init(allocator);
    defer bytes.deinit();
    for (bytes_in_order.items) |b| {
        try bytes.put(b, {});
    }

    var frontier = std.ArrayList([2]u8).init(allocator);
    defer frontier.deinit();

    try frontier.append([_]u8{ 0, 0 });

    var seen = std.AutoHashMap([2]u8, void).init(allocator);
    defer seen.deinit();

    try seen.put([_]u8{ 0, 0 }, {});

    var num_bytes = bytes_in_order.items.len;

    main: while (true) {
        while (frontier.items.len > 0) {
            var new_frontier = std.ArrayList([2]u8).init(allocator);
            for (frontier.items) |pos| {
                const x = pos[0];
                const y = pos[1];

                if (x == width - 1 and y == height - 1) {
                    break :main;
                }

                if (x > 0) {
                    const candidate = [_]u8{ x - 1, y };
                    if (!bytes.contains(candidate) and !seen.contains(candidate)) {
                        try seen.put(candidate, {});
                        try new_frontier.append(candidate);
                    }
                }

                if (x < width - 1) {
                    const candidate = [_]u8{ x + 1, y };
                    if (!bytes.contains(candidate) and !seen.contains(candidate)) {
                        try seen.put(candidate, {});
                        try new_frontier.append(candidate);
                    }
                }

                if (y > 0) {
                    const candidate = [_]u8{ x, y - 1 };
                    if (!bytes.contains(candidate) and !seen.contains(candidate)) {
                        try seen.put(candidate, {});
                        try new_frontier.append(candidate);
                    }
                }

                if (y < height - 1) {
                    const candidate = [_]u8{ x, y + 1 };
                    if (!bytes.contains(candidate) and !seen.contains(candidate)) {
                        try seen.put(candidate, {});
                        try new_frontier.append(candidate);
                    }
                }
            }

            frontier.deinit();
            frontier = new_frontier;
        }

        num_bytes -= 1;
        _ = bytes.remove(bytes_in_order.items[num_bytes]);

        var it = seen.keyIterator();
        while (it.next()) |k| {
            try frontier.append(k.*);
        }
    }

    std.debug.print("Part 2: {},{}\n", .{ bytes_in_order.items[num_bytes][0], bytes_in_order.items[num_bytes][1] });
}

pub fn main() !void {
    try part1();
    try part2();
}
