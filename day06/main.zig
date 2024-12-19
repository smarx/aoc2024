const std = @import("std");
const input = @embedFile("input.txt");

pub fn loops(rows: *std.ArrayList(std.ArrayList(u8)), startx: i32, starty: i32, allocator: std.mem.Allocator) !bool {
    var x = startx;
    var y = starty;

    var dir = [2]i32{ 0, -1 };

    var seen = std.AutoHashMap([4]i32, void).init(allocator);
    defer seen.deinit();

    while (true) {
        if (seen.contains([4]i32{ y, x, dir[0], dir[1] })) {
            return true;
        }
        try seen.put([4]i32{ y, x, dir[0], dir[1] }, void{});

        const newx = x + dir[0];
        const newy = y + dir[1];

        if (newx < 0 or newx >= rows.items[0].items.len) {
            return false;
        }

        if (newy < 0 or newy >= rows.items.len) {
            return false;
        }

        if (rows.items[@intCast(newy)].items[@intCast(newx)] == '#') {
            const tmp = dir[1];
            dir[1] = dir[0];
            dir[0] = -tmp;
        } else {
            x = newx;
            y = newy;
        }
    }
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

    var startx: i32 = 0;
    var starty: i32 = 0;

    var x: i32 = 0;
    var y: i32 = 0;

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var row = std.ArrayList(u8).init(allocator);

        for (line) |c| {
            if (c == '^') {
                startx = x;
                starty = y;
                try row.append('^');
            } else if (c == '.') {
                try row.append(0);
            } else if (c == '#') {
                try row.append('#');
            } else {
                std.debug.print("Unknown character: {}\n", .{c});
                return error.Unreachable;
            }
            x += 1;
        }

        try rows.append(row);
        y += 1;
        x = 0;
    }

    var candidateObstacles = std.AutoHashMap([2]usize, void).init(allocator);
    defer candidateObstacles.deinit();

    var visited = std.AutoHashMap([2]usize, void).init(allocator);
    defer visited.deinit();

    var dir = [2]i32{ 0, -1 };

    x = startx;
    y = starty;
    while (true) {
        try visited.put([2]usize{ @intCast(x), @intCast(y) }, {});

        const newx = x + dir[0];
        const newy = y + dir[1];

        if (newx < 0 or newx >= rows.items[0].items.len) {
            break;
        }

        if (newy < 0 or newy >= rows.items.len) {
            break;
        }

        if (rows.items[@intCast(newy)].items[@intCast(newx)] == '#') {
            const tmp = dir[1];
            dir[1] = dir[0];
            dir[0] = -tmp;
        } else {
            x = newx;
            y = newy;
            if (x != startx or y != starty) {
                try candidateObstacles.put([2]usize{ @intCast(x), @intCast(y) }, {});
            }
        }
    }

    std.debug.print("Part 1: {}\n", .{visited.count()});

    var loopCount: usize = 0;

    var keyit = candidateObstacles.keyIterator();

    while (keyit.next()) |obstacle| {
        const ox = obstacle[0];
        const oy = obstacle[1];
        rows.items[@intCast(oy)].items[@intCast(ox)] = '#';
        if (try loops(&rows, startx, starty, allocator)) {
            loopCount += 1;
        }
        rows.items[@intCast(oy)].items[@intCast(ox)] = 0;
    }

    std.debug.print("Part 2: {}\n", .{loopCount});
}
