const std = @import("std");
const input = @embedFile("input.txt");

fn extractInts(text: []const u8) ![2]i64 {
    var split = std.mem.tokenizeSequence(u8, text, ", ");
    var result: [2]i64 = undefined;
    for (0..2) |i| {
        const str = split.next() orelse return error.@"Not enough tokens";
        result[i] = try std.fmt.parseInt(i64, str[2..], 10);
    }

    return result;
}

fn doIt(part: u8, added: i64) !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var cost: i64 = 0;

    while (true) {
        const first_line = lines.next() orelse break;
        const second_line = lines.next() orelse break;
        const third_line = lines.next() orelse break;

        const a = try extractInts(first_line[10..]);
        const b = try extractInts(second_line[10..]);

        var p = try extractInts(third_line[7..]);
        p[0] += added;
        p[1] += added;

        const det = a[0] * b[1] - a[1] * b[0];

        const a_count = @divTrunc(p[0] * b[1] - p[1] * b[0], det);
        const b_count = @divTrunc(a[0] * p[1] - a[1] * p[0], det);

        if (a[0] * a_count + b[0] * b_count == p[0] and a[1] * a_count + b[1] * b_count == p[1]) {
            cost += a_count * 3 + b_count;
        }
    }

    std.debug.print("Part {}: {}\n", .{ part, cost });
}

pub fn main() !void {
    try doIt(1, 0);
    try doIt(2, 10000000000000);
}
