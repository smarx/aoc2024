const std = @import("std");
const example = @embedFile("input.txt");

pub fn canMakeValue2(target: usize, operands: []usize) bool {
    const closure = struct {
        fn concat(a: usize, b: usize) usize {
            var multiplier: usize = 1;

            while (b >= multiplier) {
                multiplier *= 10;
            }

            return a * multiplier + b;
        }

        fn inner(innerTarget: usize, innerOperands: []usize, sofar: usize) bool {
            if (innerOperands.len == 0) {
                return sofar == innerTarget;
            }

            return inner(innerTarget, innerOperands[1..], sofar + innerOperands[0]) or inner(innerTarget, innerOperands[1..], sofar * innerOperands[0]) or inner(innerTarget, innerOperands[1..], concat(sofar, innerOperands[0]));
        }
    };

    return closure.inner(target, operands[1..], operands[0]);
}

pub fn canMakeValue(target: usize, operands: []usize) bool {
    const closure = struct {
        fn inner(innerTarget: usize, innerOperands: []usize, sofar: usize) bool {
            if (innerOperands.len == 0) {
                return sofar == innerTarget;
            }

            return inner(innerTarget, innerOperands[1..], sofar + innerOperands[0]) or inner(innerTarget, innerOperands[1..], sofar * innerOperands[0]);
        }
    };

    return closure.inner(target, operands[1..], operands[0]);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var total: usize = 0;
    var total2: usize = 0;
    var lines = std.mem.tokenizeScalar(u8, example, '\n');

    while (lines.next()) |line| {
        var split = std.mem.tokenizeScalar(u8, line, ':');

        const value = try std.fmt.parseInt(usize, split.next() orelse break, 10);
        const rest = split.next() orelse break;

        var restSplit = std.mem.tokenizeScalar(u8, rest, ' ');
        var restValues = std.ArrayList(usize).init(allocator);
        defer restValues.deinit();

        while (restSplit.next()) |s| {
            const restValue = try std.fmt.parseInt(usize, s, 10);
            try restValues.append(restValue);
        }

        if (canMakeValue(value, restValues.items)) {
            total += value;
        }

        if (canMakeValue2(value, restValues.items)) {
            total2 += value;
        }
    }

    std.debug.print("Part 1: {}\n", .{total});
    std.debug.print("Part 2: {}\n", .{total2});
}
