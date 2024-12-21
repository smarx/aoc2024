const std = @import("std");
const input = @embedFile("input.txt");

const Computer = struct {
    program: []u8,
    a: u64,
    b: u64,
    c: u64,
    output: std.ArrayList(u64),
    ip: u64,

    fn combo(self: *Computer, value: u8) u64 {
        switch (value) {
            0...3 => return value,
            4 => return self.a,
            5 => return self.b,
            6 => return self.c,
            else => return 0,
        }
    }

    fn div(self: *Computer, value: u8) u64 {
        return self.a >> @intCast(self.combo(value));
    }

    fn findQuineForLast(self: *Computer, start_a: u64, n: usize) !?u64 {
        // No more outputs to match, so we're done!
        if (n == 0) {
            return start_a;
        }

        // We happen to know that each iteration of the program chops of 3
        // bits, so we're looking for a value less than 2^3.
        for (0..8) |a| {
            const candidate = (start_a << 3) + a;
            self.a = candidate;
            self.ip = 0;
            self.output.clearRetainingCapacity();

            try self.execute();

            if (self.output.items[0] == self.program[n - 1]) {
                // We found a candidate for those next three bits, but it may
                // not be workable. We have to try filling in the rest and then
                // backtrack (via recursion).
                if (try self.findQuineForLast(candidate, n - 1)) |result| {
                    return result;
                }
            }
        }

        return null;
    }

    fn execute(self: *Computer) !void {
        while (self.ip < self.program.len) {
            const i = self.program[self.ip];
            const o = self.program[self.ip + 1];
            switch (i) {
                0 => {
                    self.a = self.div(o);
                    self.ip += 2;
                },
                1 => {
                    self.b ^= o;
                    self.ip += 2;
                },
                2 => {
                    self.b = self.combo(o) % 8;
                    self.ip += 2;
                },
                3 => {
                    if (self.a == 0) {
                        self.ip += 2;
                    } else {
                        self.ip = o;
                    }
                },
                4 => {
                    self.b ^= self.c;
                    self.ip += 2;
                },
                5 => {
                    try self.output.append(self.combo(o) % 8);
                    self.ip += 2;
                },
                6 => {
                    self.b = self.div(o);
                    self.ip += 2;
                },
                7 => {
                    self.c = self.div(o);
                    self.ip += 2;
                },
                else => {
                    return error.@"Unknown opcode";
                },
            }
        }
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    const a = try std.fmt.parseInt(u64, (lines.next() orelse return)[12..], 10);
    const b = try std.fmt.parseInt(u64, (lines.next() orelse return)[12..], 10);
    const c = try std.fmt.parseInt(u64, (lines.next() orelse return)[12..], 10);

    const program_string = (lines.next() orelse return)[9..];

    var program_iterator = std.mem.tokenizeScalar(u8, program_string, ',');
    var program = std.ArrayList(u8).init(allocator);
    defer program.deinit();

    while (program_iterator.next()) |el| {
        try program.append(try std.fmt.parseInt(u8, el, 10));
    }

    var computer = Computer{ .program = program.items, .a = a, .b = b, .c = c, .ip = 0, .output = std.ArrayList(u64).init(allocator) };
    defer computer.output.deinit();

    try computer.execute();

    std.debug.print("Part 1: ", .{});
    for (computer.output.items, 0..) |el, i| {
        if (i != 0) {
            std.debug.print(",", .{});
        }
        std.debug.print("{}", .{el});
    }
    std.debug.print("\n", .{});

    std.debug.print("Part 2: {}\n", .{try computer.findQuineForLast(0, computer.program.len) orelse return error.@"No solution found."});
}
