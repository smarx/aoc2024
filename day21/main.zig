const std = @import("std");
const input = @embedFile("input.txt");

fn getLocation(c: u8, is_numeric: bool) ![2]u8 {
    switch (c) {
        '0' => return [_]u8{ 1, 3 },
        '1' => return [_]u8{ 0, 2 },
        '2' => return [_]u8{ 1, 2 },
        '3' => return [_]u8{ 2, 2 },
        '4' => return [_]u8{ 0, 1 },
        '5' => return [_]u8{ 1, 1 },
        '6' => return [_]u8{ 2, 1 },
        '7' => return [_]u8{ 0, 0 },
        '8' => return [_]u8{ 1, 0 },
        '9' => return [_]u8{ 2, 0 },
        '^' => return [_]u8{ 1, 0 },
        '<' => return [_]u8{ 0, 1 },
        'v' => return [_]u8{ 1, 1 },
        '>' => return [_]u8{ 2, 1 },
        'A' => {
            if (is_numeric) {
                return [_]u8{ 2, 3 };
            } else {
                return [_]u8{ 2, 0 };
            }
        },
        else => return error.@"Unknown key",
    }
}

fn countMoves(position: [2]u8, target: [2]u8, is_numeric: bool, remaining_levels: u8, memo: *std.AutoHashMap([5]u8, u64)) !u64 {
    if (remaining_levels == 0) {
        return 1;
    }

    const key = [_]u8{ position[0], position[1], target[0], target[1], remaining_levels };
    const prev = memo.get(key);
    if (prev) |p| {
        return p;
    }

    const dx = @as(i8, @intCast(target[0])) - @as(i8, @intCast(position[0]));
    const dy = @as(i8, @intCast(target[1])) - @as(i8, @intCast(position[1]));

    var vfirst = true;

    if (is_numeric and target[0] == 0 and position[1] == 3) {
        vfirst = true;
    } else if (is_numeric and position[0] == 0 and target[1] == 3) {
        vfirst = false;
    } else if (!is_numeric and position[0] == 0) {
        vfirst = false;
    } else if (!is_numeric and target[0] == 0) {
        vfirst = true;
    } else {
        vfirst = dx > 0;
    }

    const a = try getLocation('A', false);
    var current = a;

    var total: usize = 0;
    const vtarget = try getLocation(if (dy < 0) '^' else 'v', false);
    const htarget = try getLocation(if (dx < 0) '<' else '>', false);

    if (vfirst) {
        if (dy != 0) {
            for (0..@abs(dy)) |_| {
                total += try countMoves(current, vtarget, false, remaining_levels - 1, memo);
                current = vtarget;
            }
        }
        if (dx != 0) {
            for (0..@abs(dx)) |_| {
                total += try countMoves(current, htarget, false, remaining_levels - 1, memo);
                current = htarget;
            }
        }
    } else {
        if (dx != 0) {
            for (0..@abs(dx)) |_| {
                total += try countMoves(current, htarget, false, remaining_levels - 1, memo);
                current = htarget;
            }
        }
        if (dy != 0) {
            for (0..@abs(dy)) |_| {
                total += try countMoves(current, vtarget, false, remaining_levels - 1, memo);
                current = vtarget;
            }
        }
    }

    total += try countMoves(current, a, false, remaining_levels - 1, memo);

    try memo.put(key, total);

    return total;
}

fn getMoves(sequence: []const u8, is_numeric: bool, allocator: std.mem.Allocator) !std.ArrayList(u8) {
    var moves = std.ArrayList(u8).init(allocator);

    var current = try getLocation('A', is_numeric);
    for (sequence) |c| {
        const target = try getLocation(c, is_numeric);
        const dx = @as(i8, @intCast(target[0])) - @as(i8, @intCast(current[0]));
        const dy = @as(i8, @intCast(target[1])) - @as(i8, @intCast(current[1]));

        var vfirst = true;

        if (is_numeric and target[0] == 0 and current[1] == 3) {
            vfirst = true;
        } else if (is_numeric and current[0] == 0 and target[1] == 3) {
            vfirst = false;
        } else if (!is_numeric and current[0] == 0) {
            vfirst = false;
        } else if (!is_numeric and target[0] == 0) {
            vfirst = true;
        } else {
            vfirst = dx > 0;
        }

        if (vfirst) {
            for (0..@abs(dy)) |_| {
                try moves.append(if (dy < 0) '^' else 'v');
            }
            for (0..@abs(dx)) |_| {
                try moves.append(if (dx < 0) '<' else '>');
            }
        } else {
            for (0..@abs(dx)) |_| {
                try moves.append(if (dx < 0) '<' else '>');
            }
            for (0..@abs(dy)) |_| {
                try moves.append(if (dy < 0) '^' else 'v');
            }
        }

        try moves.append('A');

        current = target;
    }

    return moves;
}

fn doIt(part: u8, robots: u8) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var memo = std.AutoHashMap([5]u8, u64).init(allocator);
    defer memo.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var sum: usize = 0;
    while (lines.next()) |line| {
        var current = try getLocation('A', true);
        var count: usize = 0;
        for (line) |c| {
            const target = try getLocation(c, true);
            count += try countMoves(current, target, true, robots, &memo);
            current = target;
        }

        var numeric_code: usize = 0;
        for (line) |c| {
            if (c >= '0' and c <= '9') {
                numeric_code = numeric_code * 10 + (c - '0');
            }
        }

        sum += numeric_code * count;
    }

    std.debug.print("Part {}: {}\n", .{ part, sum });
}

pub fn main() !void {
    try doIt(1, 3);
    try doIt(2, 26);
}
