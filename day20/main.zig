const std = @import("std");
const input = @embedFile("input.txt");

const directions = [_][2]i32{
    [_]i32{ -1, 0 },
    [_]i32{ 0, 1 },
    [_]i32{ 1, 0 },
    [_]i32{ 0, -1 },
};

fn visualize(rows: *std.ArrayList(std.ArrayList(i64)), curx: usize, cury: usize) void {
    for (rows.items, 0..) |row, y| {
        for (row.items, 0..) |c, x| {
            if (x == curx and y == cury) {
                std.debug.print("*", .{});
            } else if (c == -1) {
                std.debug.print(".", .{});
            } else if (c == -2) {
                std.debug.print("#", .{});
            } else {
                std.debug.print("o", .{});
            }
        }
        std.debug.print("\n", .{});
    }

    std.debug.print("\n", .{});
}

fn countGoodCheats(rows: *std.ArrayList(std.ArrayList(i64)), radius: i64, threshold: usize) usize {
    const width = rows.items[0].items.len;
    const height = rows.items.len;

    var count: usize = 0;

    for (rows.items, 0..) |row, y| {
        for (row.items, 0..) |value, x| {
            if (value < 0) {
                continue;
            }

            var dy: i64 = -radius;
            while (dy <= radius) : (dy += 1) {
                var dx: i64 = -radius + @as(i64, @intCast(@abs(dy)));
                while (dx <= radius - @as(i64, @intCast(@abs(dy)))) : (dx += 1) {
                    const nx = @as(i32, @intCast(x)) + dx;
                    const ny = @as(i32, @intCast(y)) + dy;

                    if (nx < 0 or nx >= width or ny < 0 or ny >= height) {
                        continue;
                    }

                    if (nx == x and ny == y) {
                        continue;
                    }

                    const distance = @as(i64, @intCast(@abs(dx))) + @as(i64, @intCast(@abs(dy)));

                    const newx: usize = @intCast(nx);
                    const newy: usize = @intCast(ny);

                    const dest = rows.items[newy].items[newx];
                    if (dest < 0) {
                        continue;
                    }

                    const cheat_value = dest - value - distance;

                    if (cheat_value >= threshold) {
                        count += 1;
                    }
                }
            }
        }
    }

    return count;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var rows = std.ArrayList(std.ArrayList(i64)).init(allocator);
    defer {
        for (rows.items) |row| {
            row.deinit();
        }
        rows.deinit();
    }

    var startx: usize = 0;
    var starty: usize = 0;
    var endx: usize = 0;
    var endy: usize = 0;

    {
        var lines = std.mem.tokenizeScalar(u8, input, '\n');
        var y: usize = 0;
        while (lines.next()) |line| {
            var row = std.ArrayList(i64).init(allocator);
            for (line, 0..) |c, x| {
                if (c == 'S') {
                    startx = x;
                    starty = y;
                    try row.append(-1);
                } else if (c == 'E') {
                    endx = x;
                    endy = y;
                    try row.append(-1);
                } else if (c == '#') {
                    try row.append(-2);
                } else {
                    try row.append(-1);
                }
            }
            try rows.append(row);
            y += 1;
        }
    }

    {
        var x = startx;
        var y = starty;
        var steps: usize = 0;
        while (true) {
            rows.items[y].items[x] = @intCast(steps);
            if (x == endx and y == endy) {
                break;
            }
            for (directions) |dir| {
                const nextx: usize = @intCast(@as(i32, @intCast(x)) + dir[0]);
                const nexty: usize = @intCast(@as(i32, @intCast(y)) + dir[1]);

                if (rows.items[nexty].items[nextx] == -1 or (nextx == endx and nexty == endy)) {
                    x = nextx;
                    y = nexty;
                    break;
                }
            }

            steps += 1;
            // visualize(&rows, x, y);
        }
    }

    std.debug.print("Part 1: {}\n", .{countGoodCheats(&rows, 2, 100)});
    std.debug.print("Part 2: {}\n", .{countGoodCheats(&rows, 20, 100)});
}
