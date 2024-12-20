const std = @import("std");
const input = @embedFile("input.txt");

const Cell = struct {
    plant: u8,
    region: ?usize,
};

const directions = [_][2]i32{
    [_]i32{ -1, 0 },
    [_]i32{ 0, 1 },
    [_]i32{ 1, 0 },
    [_]i32{ 0, -1 },
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var rows = std.ArrayList(std.ArrayList(Cell)).init(allocator);
    defer {
        for (rows.items) |row| {
            row.deinit();
        }
        rows.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    while (lines.next()) |line| {
        var row = std.ArrayList(Cell).init(allocator);
        for (line) |c| {
            try row.append(Cell{ .plant = c, .region = null });
        }
        try rows.append(row);
    }

    const width = rows.items[0].items.len;
    const height = rows.items.len;

    var region: usize = 0;
    var cost: usize = 0;
    var discounted_cost: usize = 0;

    for (0..height) |y| {
        for (0..width) |x| {
            var cell = &rows.items[y].items[x];

            if (cell.region != null) {
                continue;
            }

            cell.region = region;

            var cells = std.ArrayList([2]usize).init(allocator);
            defer cells.deinit();

            var area: usize = 0;
            var perimeter: usize = 0;

            var frontier = std.AutoHashMap([2]usize, void).init(allocator);
            defer frontier.deinit();

            try frontier.put([_]usize{ x, y }, void{});

            while (frontier.count() > 0) {
                var new_frontier = std.AutoHashMap([2]usize, void).init(allocator);

                var it = frontier.keyIterator();

                while (it.next()) |f| {
                    try cells.append(f.*);

                    area += 1;
                    perimeter += 4;

                    const fx = f[0];
                    const fy = f[1];

                    for (directions) |dir| {
                        const nx: i32 = @as(i32, @intCast(fx)) + dir[0];
                        const ny: i32 = @as(i32, @intCast(fy)) + dir[1];

                        if (nx < 0 or nx >= width or ny < 0 or ny >= height) {
                            continue;
                        }

                        var neighbor = &rows.items[@intCast(ny)].items[@intCast(nx)];

                        if (neighbor.plant != cell.plant) {
                            continue;
                        }

                        if (neighbor.region == region) {
                            perimeter -= 1;
                            continue;
                        }

                        if (neighbor.region != null) {
                            continue;
                        }

                        perimeter -= 1;
                        neighbor.region = region;
                        try new_frontier.put([_]usize{ @intCast(nx), @intCast(ny) }, void{});
                    }
                }

                frontier.deinit();
                frontier = new_frontier;
            }

            var corners: usize = 0;
            for (cells.items) |c| {
                for (0..4) |i| {
                    const first_direction = directions[i];
                    const second_direction = directions[(i + 1) % 4];

                    const first_nx = @as(i32, @intCast(c[0])) + first_direction[0];
                    const first_ny = @as(i32, @intCast(c[1])) + first_direction[1];
                    const second_nx = @as(i32, @intCast(c[0])) + second_direction[0];
                    const second_ny = @as(i32, @intCast(c[1])) + second_direction[1];

                    const both_nx = @as(i32, @intCast(c[0])) + first_direction[0] + second_direction[0];
                    const both_ny = @as(i32, @intCast(c[1])) + first_direction[1] + second_direction[1];

                    var first_region: ?usize = null;
                    if (first_nx >= 0 and first_nx < width and first_ny >= 0 and first_ny < height) {
                        first_region = rows.items[@intCast(first_ny)].items[@intCast(first_nx)].region;
                    }

                    var second_region: ?usize = null;
                    if (second_nx >= 0 and second_nx < width and second_ny >= 0 and second_ny < height) {
                        second_region = rows.items[@intCast(second_ny)].items[@intCast(second_nx)].region;
                    }

                    var both_region: ?usize = null;
                    if (both_nx >= 0 and both_nx < width and both_ny >= 0 and both_ny < height) {
                        both_region = rows.items[@intCast(both_ny)].items[@intCast(both_nx)].region;
                    }

                    if ((first_region != region and second_region != region) or (first_region == region and second_region == region and both_region != region)) {
                        corners += 1;
                    }
                }
            }

            cost += area * perimeter;
            discounted_cost += area * corners;
            region += 1;
        }
    }

    std.debug.print("Part 1: {}\n", .{cost});
    std.debug.print("Part 2: {}\n", .{discounted_cost});
}
