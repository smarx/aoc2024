const std = @import("std");
const input = @embedFile("data.txt");

pub fn part1(as: *std.ArrayList(i32), bs: *std.ArrayList(i32)) !void {
    std.mem.sort(i32, as.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, bs.items, {}, std.sort.asc(i32));

    var total: u32 = 0;
    for (as.items, bs.items) |a, b| {
        total += @abs(a - b);
    }
    std.debug.print("Part 1: {d}\n", .{total});
}

pub fn part2(as: *std.ArrayList(i32), bs: *std.ArrayList(i32)) !void {
    var counts = std.AutoHashMap(i32, i32).init(std.heap.page_allocator);
    defer counts.deinit();

    for (bs.items) |b| {
        try counts.put(b, (counts.get(b) orelse 0) + 1);
    }

    var total: i32 = 0;
    for (as.items) |a| {
        total += a * (counts.get(a) orelse 0);
    }

    std.debug.print("Part 2: {d}\n", .{total});
}

pub fn main() !void {
    var as = std.ArrayList(i32).init(std.heap.page_allocator);
    defer as.deinit();

    var bs = std.ArrayList(i32).init(std.heap.page_allocator);
    defer bs.deinit();

    var it = std.mem.tokenizeScalar(u8, input, '\n');
    while (it.next()) |line| {
        var words = std.mem.tokenizeScalar(u8, line, ' ');
        try as.append(try std.fmt.parseInt(i32, words.next().?, 10));
        try bs.append(try std.fmt.parseInt(i32, words.next().?, 10));
    }

    try part1(&as, &bs);
    try part2(&as, &bs);
}
