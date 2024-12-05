const std = @import("std");
const input = @embedFile("input.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    var constraints = std.AutoHashMap(usize, std.ArrayList(usize)).init(allocator);
    defer {
        var vit = constraints.valueIterator();
        while (vit.next()) |value| {
            value.deinit();
        }
        constraints.deinit();
    }

    var it = std.mem.splitScalar(u8, input, '\n');

    while (it.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var split = std.mem.tokenizeScalar(u8, line, '|');
        const left = try std.fmt.parseInt(usize, split.next().?, 10);
        const right = try std.fmt.parseInt(usize, split.next().?, 10);

        var existing = constraints.getPtr(right);
        if (existing) |*list| {
            try list.*.append(left);
        } else {
            var list = std.ArrayList(usize).init(allocator);
            try list.append(left);
            try constraints.put(right, list);
        }
    }

    var part1_total: usize = 0;
    var part2_total: usize = 0;

    while (it.next()) |line| {
        if (line.len == 0) {
            break;
        }

        var it2 = std.mem.splitScalar(u8, line, ',');

        var disallowed = std.AutoHashMap(usize, void).init(allocator);
        defer disallowed.deinit();

        var ints = std.ArrayList(usize).init(allocator);
        defer ints.deinit();

        while (it2.next()) |string_value| {
            try ints.append(try std.fmt.parseInt(usize, string_value, 10));
        }

        for (ints.items) |int_value| {
            if (disallowed.get(int_value) != null) {
                break;
            }

            if (constraints.getPtr(int_value)) |*list| {
                for (list.*.items) |value| {
                    try disallowed.put(value, {});
                }
            }
        } else {
            part1_total += ints.items[ints.items.len / 2];
            continue;
        }

        var set = std.AutoHashMap(usize, void).init(allocator);
        defer set.deinit();

        for (ints.items) |value| {
            try set.put(value, {});
        }

        for (0..ints.items.len) |i| {
            find_next: for (i..ints.items.len) |j| {
                const lefts = constraints.getPtr(ints.items[j]);
                if (lefts) |*list| {
                    for (list.*.items) |value| {
                        if (set.get(value) != null) {
                            continue :find_next;
                        }
                    }
                }

                const to_move = ints.items[j];
                ints.items[j] = ints.items[i];
                ints.items[i] = to_move;

                _ = set.remove(to_move);
                break;
            }
        }

        part2_total += ints.items[ints.items.len / 2];
    }

    std.debug.print("Part 1: {d}\n", .{part1_total});
    std.debug.print("Part 2: {d}\n", .{part2_total});
}
