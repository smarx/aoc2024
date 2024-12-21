const std = @import("std");
const input = @embedFile("input.txt");

const Checker = struct {
    towels: [][]const u8,
    memo: std.StringHashMap(u64),
    fn countWays(self: *Checker, pattern: []const u8) !u64 {
        if (pattern.len == 0) {
            return 1;
        }

        const memoized = self.memo.get(pattern);

        if (memoized) |m| {
            return m;
        }

        var ways: u64 = 0;
        for (self.towels) |t| {
            if (std.mem.startsWith(u8, pattern, t)) {
                ways += try self.countWays(pattern[t.len..]);
            }
        }

        try self.memo.put(pattern, ways);
        return ways;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var towels = std.ArrayList([]const u8).init(allocator);
    defer towels.deinit();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var towel_iterator = std.mem.tokenizeSequence(u8, lines.next() orelse return, ", ");

    while (towel_iterator.next()) |t| {
        try towels.append(t);
    }

    var checker = Checker{ .towels = towels.items, .memo = std.StringHashMap(u64).init(allocator) };
    defer checker.memo.deinit();

    var possible_count: usize = 0;
    var total_ways: usize = 0;
    while (lines.next()) |pattern| {
        const ways = try checker.countWays(pattern);
        if (ways > 0) {
            possible_count += 1;
        }
        total_ways += ways;
    }

    std.debug.print("Part 1: {}\n", .{possible_count});
    std.debug.print("Part 2: {}\n", .{total_ways});
}
