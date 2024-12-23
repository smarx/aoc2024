const std = @import("std");
const input = @embedFile("input.txt");

fn getNext(p: u64) u64 {
    var n = p;
    n = (n << 6) ^ n;
    n %= 16777216;

    n = (n >> 5) ^ n;
    n %= 16777216;

    n = (n << 11) ^ n;
    n %= 16777216;

    return n;
}

fn decode(encoded: u64) void {
    var n = encoded;
    const fourth: i64 = @intCast(n % 19);
    n /= 19;
    const third: i64 = @intCast(n % 19);
    n /= 19;
    const second: i64 = @intCast(n % 19);
    n /= 19;
    const first: i64 = @intCast(n % 19);
    n /= 19;

    std.debug.print("{} {} {} {}\n", .{ first - 9, second - 9, third - 9, fourth - 9 });
}

const nineteen_cubed = std.math.pow(u64, 19, 3);
fn applyNew(n: u64, new: u64) u64 {
    return (n % nineteen_cubed) * 19 + new;
}

fn part1() !void {
    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var total: usize = 0;
    while (lines.next()) |line| {
        var n = try std.fmt.parseInt(u64, line, 10);
        for (0..2000) |_| {
            n = getNext(n);
        }
        total += n;
    }

    std.debug.print("Part 1: {}\n", .{total});
}

const combos = std.math.pow(u64, 19, 4);

fn part2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var profits: [combos]u64 = undefined;
    var seen: [combos]bool = undefined;

    @memset(&profits, 0);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines.next()) |line| {
        @memset(&seen, false);
        var encoded: u64 = 0;
        var n: u64 = try std.fmt.parseInt(u64, line, 10);
        var prev = n % 10;
        for (0..2000) |i| {
            n = getNext(n);
            const price = n % 10;
            encoded = applyNew(encoded, price + 9 - prev);
            if (i >= 4) {
                if (!seen[encoded]) {
                    seen[encoded] = true;
                    profits[encoded] += price;
                }
            }
            prev = price;
        }
    }

    var best_profit: u64 = 0;
    for (profits) |p| {
        if (p > best_profit) {
            best_profit = p;
        }
    }

    std.debug.print("Part 2: {}\n", .{best_profit});
}

pub fn main() !void {
    try part1();
    try part2();
}
