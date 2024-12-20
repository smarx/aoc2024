const std = @import("std");
const input = @embedFile("input.txt");
const width = 101;
const height = 103;

fn extractInts(text: []const u8) ![2]i64 {
    var split = std.mem.tokenizeScalar(u8, text[2..], ',');
    var result: [2]i64 = undefined;
    for (0..2) |i| {
        const str = split.next() orelse return error.@"Not enough tokens";
        result[i] = try std.fmt.parseInt(i64, str, 10);
    }

    return result;
}

const Robot = struct {
    p: [2]i64,
    v: [2]i64,
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var robots = std.ArrayList(Robot).init(allocator);
    defer robots.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var quadrants = [4]u64{ 0, 0, 0, 0 };

    while (lines.next()) |line| {
        var halves = std.mem.tokenizeScalar(u8, line, ' ');

        const p = try extractInts(halves.next() orelse break);
        const v = try extractInts(halves.next() orelse break);

        try robots.append(Robot{ .p = p, .v = v });

        const px = @mod(p[0] + v[0] * 100, width);
        const py = @mod(p[1] + v[1] * 100, height);

        if (px == width / 2 or py == height / 2) {
            continue;
        }

        quadrants[@as(usize, @intFromBool(px <= width / 2)) * 2 + @as(usize, @intFromBool(py <= height / 2))] += 1;
    }

    var product: usize = 1;

    for (quadrants) |q| {
        product *= q;
    }

    std.debug.print("Part 1: {}\n", .{product});

    var seconds: i64 = 0;
    var done = false;
    var positions = std.AutoHashMap([2]i64, void).init(allocator);
    defer positions.deinit();

    while (!done) : (seconds += 1) {
        positions.clearRetainingCapacity();
        for (robots.items) |robot| {
            const px = @mod(robot.p[0] + robot.v[0] * seconds, width);
            const py = @mod(robot.p[1] + robot.v[1] * seconds, height);

            try positions.put([_]i64{ px, py }, {});
        }

        // std.debug.print("Second {}\n", .{seconds});
        var in_a_row: usize = 0;
        for (0..height) |y| {
            for (0..width) |x| {
                if (positions.contains([_]i64{ @intCast(x), @intCast(y) })) {
                    // std.debug.print("#", .{});
                    in_a_row += 1;
                    if (in_a_row > 10) {
                        done = true;
                    }
                } else {
                    // std.debug.print(".", .{});
                    in_a_row = 0;
                }
            }
            // std.debug.print("\n", .{});
        }
    }

    std.debug.print("Part 2: {}\n", .{seconds - 1});
}
