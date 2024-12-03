const std = @import("std");
const input = @embedFile("data.txt");

const Parser = struct {
    const ParseError = error{
        InvalidCharacter,
        InvalidLength,
    };

    const Instruction = union(enum) {
        multiply: struct {
            x: usize,
            y: usize,
        },
        toggle: bool,
    };

    remainder: []const u8,

    fn readInt(self: *Parser, len: usize) !usize {
        if (len < 1 or len > 3) {
            return ParseError.InvalidLength;
        }

        for (self.remainder[0..len]) |c| {
            if (!std.ascii.isDigit(c)) {
                return ParseError.InvalidCharacter;
            }
        }

        const result = try std.fmt.parseInt(usize, self.remainder[0..len], 10);

        self.remainder = self.remainder[len + 1 ..];
        return result;
    }

    pub fn nextInstruction(self: *Parser) ?Instruction {
        while (self.remainder.len > 0) {
            if (std.mem.startsWith(u8, self.remainder, "do()")) {
                self.remainder = self.remainder[4..];
                return .{ .toggle = true };
            }

            if (std.mem.startsWith(u8, self.remainder, "don't()")) {
                self.remainder = self.remainder[7..];
                return .{ .toggle = false };
            }

            if (std.mem.startsWith(u8, self.remainder, "mul(")) {
                self.remainder = self.remainder[4..];
                const comma = std.mem.indexOf(u8, self.remainder, ",") orelse continue;
                const x = self.readInt(comma) catch continue;
                const paren = std.mem.indexOf(u8, self.remainder, ")") orelse continue;
                const y = self.readInt(paren) catch continue;

                return .{ .multiply = .{ .x = x, .y = y } };
            }

            self.remainder = self.remainder[1..];
        }

        return null;
    }
};

pub fn part1() !void {
    var total: usize = 0;

    var parser = Parser{ .remainder = input };

    while (parser.nextInstruction()) |instruction| {
        switch (instruction) {
            .multiply => |mul| {
                total += mul.x * mul.y;
            },
            else => {},
        }
    }

    std.debug.print("Part 1: {d}\n", .{total});
}

pub fn part2() !void {
    var total: usize = 0;

    var parser = Parser{ .remainder = input };
    var enabled: bool = true;

    while (parser.nextInstruction()) |instruction| {
        switch (instruction) {
            .multiply => |mul| {
                if (enabled) {
                    total += mul.x * mul.y;
                }
            },
            .toggle => |toggle| {
                enabled = toggle;
            },
        }
    }

    std.debug.print("Part 2: {d}\n", .{total});
}

pub fn main() !void {
    try part1();
    try part2();
}
