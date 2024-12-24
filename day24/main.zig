const std = @import("std");
const input = @embedFile("input.txt");

const Operator = enum {
    AND,
    OR,
    XOR,
};

const Gate = struct {
    a: []const u8,
    b: []const u8,
    operator: Operator,

    fn init(o1: []const u8, op: []const u8, o2: []const u8) Gate {
        var operator: Operator = undefined;

        if (std.mem.eql(u8, op, "AND")) {
            operator = .AND;
        } else if (std.mem.eql(u8, op, "OR")) {
            operator = .OR;
        } else if (std.mem.eql(u8, op, "XOR")) {
            operator = .XOR;
        }

        return Gate{
            .a = o1,
            .b = o2,
            .operator = operator,
        };
    }

    fn evaluate(self: Gate, a: u8, b: u8) u8 {
        switch (self.operator) {
            .AND => return a & b,
            .OR => return a | b,
            .XOR => return a ^ b,
        }
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var values = std.StringHashMap(u8).init(allocator);
    var gates = std.StringHashMap(Gate).init(allocator);

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var colon_split = std.mem.tokenizeSequence(u8, line, ": ");
        const before = colon_split.next() orelse break;
        const after = colon_split.next();

        if (after) |v| {
            try values.put(before, try std.fmt.parseInt(u8, v, 10));
        } else {
            var space_split = std.mem.tokenizeScalar(u8, before, ' ');
            const o1 = space_split.next() orelse break;
            const op = space_split.next() orelse break;
            const o2 = space_split.next() orelse break;
            _ = space_split.next(); // consume ->
            const dest = space_split.next() orelse break;

            try gates.put(dest, Gate.init(o1, op, o2));

            // For part2, print out graphviz
            // std.debug.print("{s} -> {s}\n", .{ o1, dest });
            // std.debug.print("{s} -> {s}\n", .{ o2, dest });
            // std.debug.print("{s} [label=\"{s}\\n{s}\"]\n", .{ dest, op, dest });
        }
    }

    while (gates.count() > 0) {
        var it = gates.iterator();
        while (it.next()) |gate| {
            const k = gate.key_ptr;
            const v = gate.value_ptr;

            const a = values.get(v.a);
            const b = values.get(v.b);

            if (a != null and b != null) {
                try values.put(k.*, v.evaluate(a.?, b.?));
                _ = gates.remove(k.*);
                break;
            }
        }
    }

    var sum: usize = 0;

    var it = values.iterator();
    while (it.next()) |v| {
        if (v.key_ptr.*[0] == 'z') {
            const place = try std.fmt.parseInt(u6, v.key_ptr.*[1..], 10);
            sum += @as(u64, @intCast(v.value_ptr.*)) << place;
        }
    }

    std.debug.print("Part 1: {}\n", .{sum});
}
