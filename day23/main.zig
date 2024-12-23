const std = @import("std");
const input = @embedFile("input.txt");

fn add(a: [2]u8, b: [2]u8, adjacency: *std.AutoHashMap([2]u8, std.AutoHashMap([2]u8, void)), allocator: std.mem.Allocator) !void {
    const existing = adjacency.getPtr(a);
    if (existing) |e| {
        try e.put(b, {});
    } else {
        var s = std.AutoHashMap([2]u8, void).init(allocator);
        try s.put(b, {});
        try adjacency.put(a, s);
    }
}

const VertexSet = std.AutoHashMap([2]u8, void);

fn setIntersection(as: *const VertexSet, bs: *const VertexSet, allocator: std.mem.Allocator) !VertexSet {
    var result = VertexSet.init(allocator);

    var it = as.keyIterator();
    while (it.next()) |a| {
        if (bs.contains(a.*)) {
            try result.put(a.*, {});
        }
    }

    return result;
}

fn setAdd(as: *VertexSet, b: [2]u8, allocator: std.mem.Allocator) !VertexSet {
    var result = VertexSet.init(allocator);

    var it = as.keyIterator();
    while (it.next()) |a| {
        try result.put(a.*, {});
    }

    try result.put(b, {});

    return result;
}

fn bronKerbosch(r: *VertexSet, p: *VertexSet, x: *VertexSet, adjacency: *const std.AutoHashMap([2]u8, VertexSet), allocator: std.mem.Allocator, biggest: *std.ArrayList([2]u8)) !void {
    if (p.count() == 0 and x.count() == 0) {
        if (r.count() > biggest.items.len) {
            biggest.clearRetainingCapacity();
            var it = r.keyIterator();
            while (it.next()) |k| {
                try biggest.append(k.*);
            }
        }

        return;
    }

    var vit = p.keyIterator();
    while (vit.next()) |v| {
        var new_r = try setAdd(r, v.*, allocator);
        defer new_r.deinit();

        var new_p = try setIntersection(p, &adjacency.get(v.*).?, allocator);
        defer new_p.deinit();

        var new_x = try setIntersection(x, &adjacency.get(v.*).?, allocator);
        defer new_x.deinit();

        try bronKerbosch(&new_r, &new_p, &new_x, adjacency, allocator, biggest);

        _ = p.remove(v.*);
        try x.put(v.*, {});
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var adjacency = std.AutoHashMap([2]u8, std.AutoHashMap([2]u8, void)).init(allocator);
    defer {
        var it = adjacency.valueIterator();
        while (it.next()) |v| {
            v.deinit();
        }
        adjacency.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    while (lines.next()) |line| {
        const a = line[0..2];
        const b = line[3..5];

        try add(a.*, b.*, &adjacency, allocator);
        try add(b.*, a.*, &adjacency, allocator);
    }

    var count: usize = 0;

    var it = adjacency.iterator();
    while (it.next()) |entry| {
        const start = entry.key_ptr.*;

        var first = entry.value_ptr.keyIterator();
        while (first.next()) |f| {
            if (!std.mem.lessThan(u8, &start, f)) {
                continue;
            }
            var second = adjacency.get(f.*).?.keyIterator();
            while (second.next()) |s| {
                if (!std.mem.lessThan(u8, f, s)) {
                    continue;
                }

                if (adjacency.get(s.*).?.contains(start)) {
                    if (start[0] == 't' or f[0] == 't' or s[0] == 't') {
                        count += 1;
                    }
                }
            }
        }
    }

    std.debug.print("Part 1: {}\n", .{count});

    var p = VertexSet.init(allocator);
    defer p.deinit();

    var vit = adjacency.keyIterator();
    while (vit.next()) |v| {
        try p.put(v.*, {});
    }

    var r = VertexSet.init(allocator);
    defer r.deinit();

    var x = VertexSet.init(allocator);
    defer x.deinit();

    var biggest = std.ArrayList([2]u8).init(allocator);
    defer biggest.deinit();

    try bronKerbosch(&r, &p, &x, &adjacency, allocator, &biggest);

    const Sorter = struct {
        pub fn lessThan(_: void, a: [2]u8, b: [2]u8) bool {
            if (a[0] == b[0]) return a[1] < b[1];
            return a[0] < b[0];
        }
    };
    std.mem.sort([2]u8, biggest.items, {}, Sorter.lessThan);

    std.debug.print("Part 2: ", .{});
    for (biggest.items, 0..) |b, i| {
        if (i > 0) {
            std.debug.print(",", .{});
        }
        std.debug.print("{s}", .{b});
    }
    std.debug.print("\n", .{});
}
