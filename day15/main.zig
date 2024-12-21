const std = @import("std");
const input = @embedFile("input.txt");

fn visualize(rows: *std.ArrayList(std.ArrayList(u8)), robot_x: usize, robot_y: usize) void {
    for (rows.items, 0..) |row, y| {
        for (row.items, 0..) |c, x| {
            if (x == robot_x and y == robot_y) {
                std.debug.print("@", .{});
            } else {
                std.debug.print("{c}", .{c});
            }
        }
        std.debug.print("\n", .{});
    }

    std.debug.print("\n", .{});
}

fn canMove(rows: *std.ArrayList(std.ArrayList(u8)), x: usize, y: usize, dir: [2]i32) !bool {
    const nx: usize = @intCast(@as(i32, @intCast(x)) + dir[0]);
    const ny: usize = @intCast(@as(i32, @intCast(y)) + dir[1]);

    const cell = rows.items[ny].items[nx];

    if (cell == '.') {
        return true;
    }

    if (cell == '#') {
        return false;
    }

    if (cell == '[') {
        if (dir[0] == 1) {
            return try canMove(rows, nx + 1, ny, dir);
        } else if (dir[0] == -1) {
            return try canMove(rows, nx, ny, dir);
        } else {
            return try canMove(rows, nx, ny, dir) and try canMove(rows, nx + 1, ny, dir);
        }
    }

    if (cell == ']') {
        if (dir[0] == -1) {
            return try canMove(rows, nx - 1, ny, dir);
        } else if (dir[0] == 1) {
            return try canMove(rows, nx, ny, dir);
        } else {
            return try canMove(rows, nx, ny, dir) and try canMove(rows, nx - 1, ny, dir);
        }
    }

    return error.@"unknown cell type";
}

fn doMove(rows: *std.ArrayList(std.ArrayList(u8)), x: usize, y: usize, dir: [2]i32) !void {
    const nx: usize = @intCast(@as(i32, @intCast(x)) + dir[0]);
    const ny: usize = @intCast(@as(i32, @intCast(y)) + dir[1]);

    const cell = rows.items[ny].items[nx];

    if (cell == '[') {
        if (dir[0] == -1) {
            try doMove(rows, nx, ny, dir);
        } else {
            try doMove(rows, nx + 1, ny, dir);
            try doMove(rows, nx, ny, dir);
        }
    } else if (cell == ']') {
        if (dir[0] == 1) {
            try doMove(rows, nx, ny, dir);
        } else {
            try doMove(rows, nx - 1, ny, dir);
            try doMove(rows, nx, ny, dir);
        }
    }

    rows.items[ny].items[nx] = rows.items[y].items[x];
    rows.items[y].items[x] = '.';
}

pub fn part2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var split = std.mem.tokenizeSequence(u8, input, "\n\n");
    const map = split.next() orelse return error.@"Couldn't find map.";
    const moves = split.next() orelse return error.@"Couldn't find instructions.";

    var rows = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer {
        for (rows.items) |row| {
            row.deinit();
        }
        rows.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, map, '\n');
    var startx: usize = 0;
    var starty: usize = 0;
    {
        var y: usize = 0;
        while (lines.next()) |line| : (y += 1) {
            var row = std.ArrayList(u8).init(allocator);
            var x: usize = 0;
            for (line) |c| {
                if (c == '@') {
                    startx = x;
                    starty = y;
                    try row.append('.');
                    try row.append('.');
                } else if (c == 'O') {
                    try row.append('[');
                    try row.append(']');
                } else {
                    try row.append(c);
                    try row.append(c);
                }
                x += 2;
            }
            try rows.append(row);
        }
    }

    var x: i32 = @intCast(startx);
    var y: i32 = @intCast(starty);

    for (moves) |move| {
        if (move == '\n') {
            continue;
        }

        // visualize(&rows, @intCast(x), @intCast(y));
        // std.debug.print("Move: {c}\n", .{move});

        var dir: [2]i32 = undefined;
        switch (move) {
            '^' => {
                dir = [_]i32{ 0, -1 };
            },
            'v' => {
                dir = [_]i32{ 0, 1 };
            },
            '<' => {
                dir = [_]i32{ -1, 0 };
            },
            '>' => {
                dir = [_]i32{ 1, 0 };
            },
            else => {
                return error.@"Unknown character";
            },
        }

        if (try canMove(&rows, @intCast(x), @intCast(y), dir)) {
            try doMove(&rows, @intCast(x), @intCast(y), dir);
            x += dir[0];
            y += dir[1];
        }
    }

    var total: usize = 0;
    for (rows.items, 0..) |row, box_y| {
        for (row.items, 0..) |c, box_x| {
            if (c == '[') {
                total += 100 * box_y + box_x;
            }
        }
    }

    std.debug.print("Part 2: {}\n", .{total});
}

fn part1() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var split = std.mem.tokenizeSequence(u8, input, "\n\n");
    const map = split.next() orelse return error.@"Couldn't find map.";
    const moves = split.next() orelse return error.@"Couldn't find instructions.";

    var rows = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer {
        for (rows.items) |row| {
            row.deinit();
        }
        rows.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, map, '\n');
    var startx: usize = 0;
    var starty: usize = 0;
    {
        var y: usize = 0;
        while (lines.next()) |line| : (y += 1) {
            var row = std.ArrayList(u8).init(allocator);
            for (line, 0..) |c, x| {
                if (c == '@') {
                    startx = x;
                    starty = y;
                    try row.append('.');
                } else {
                    try row.append(c);
                }
            }
            try rows.append(row);
        }
    }

    var x: i32 = @intCast(startx);
    var y: i32 = @intCast(starty);

    for (moves) |move| {
        if (move == '\n') {
            continue;
        }

        // visualize(&rows, @intCast(x), @intCast(y));
        // std.debug.print("Move: {c}\n", .{move});

        var dir: [2]i32 = undefined;
        switch (move) {
            '^' => {
                dir = [_]i32{ 0, -1 };
            },
            'v' => {
                dir = [_]i32{ 0, 1 };
            },
            '<' => {
                dir = [_]i32{ -1, 0 };
            },
            '>' => {
                dir = [_]i32{ 1, 0 };
            },
            else => {
                return error.@"Unknown character";
            },
        }

        const nx = x + dir[0];
        const ny = y + dir[1];

        if (rows.items[@intCast(ny)].items[@intCast(nx)] == '.') {
            x = nx;
            y = ny;
            continue;
        } else if (rows.items[@intCast(ny)].items[@intCast(nx)] == '#') {
            continue;
        }

        var bx = nx;
        var by = ny;
        while (rows.items[@intCast(by)].items[@intCast(bx)] == 'O') {
            bx += dir[0];
            by += dir[1];
        }

        if (rows.items[@intCast(by)].items[@intCast(bx)] == '.') {
            rows.items[@intCast(by)].items[@intCast(bx)] = 'O';
            rows.items[@intCast(ny)].items[@intCast(nx)] = '.';
            x = nx;
            y = ny;
        }
    }

    var total: usize = 0;
    for (rows.items, 0..) |row, box_y| {
        for (row.items, 0..) |c, box_x| {
            if (c == 'O') {
                total += 100 * box_y + box_x;
            }
        }
    }

    std.debug.print("Part 1: {}\n", .{total});
}

pub fn main() !void {
    try part1();
    try part2();
}
