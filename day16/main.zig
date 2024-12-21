const std = @import("std");
const input = @embedFile("input.txt");

const directions = [_][2]i8{ .{ 1, 0 }, .{ 0, 1 }, .{ -1, 0 }, .{ 0, -1 } };

const Node = struct {
    pos: Position,
    cost: usize,
    prev: std.ArrayList(*Node),
};

const Position = struct {
    pt: Point,
    dir: usize,
};

const Point = struct {
    x: usize,
    y: usize,
};

fn h(node: *Node, end: Point) usize {
    const point = node.pos.pt;
    const distance = @abs(@as(i32, @intCast(end.x)) - @as(i32, @intCast(point.x))) + @abs(@as(i32, @intCast(end.y)) - @as(i32, @intCast(point.y)));
    const dir = directions[node.pos.dir];

    // if we're going the wrong way, we'll have to turn at least twice
    if (dir[0] == -1 and end.x > point.x) {
        return 2000 + distance;
    }
    if (dir[0] == 1 and end.x < point.x) {
        return 2000 + distance;
    }
    if (dir[1] == -1 and end.y > point.y) {
        return 2000 + distance;
    }
    if (dir[1] == 1 and end.y < point.y) {
        return 2000 + distance;
    }

    // if we're not moving along the needed axis, we'll have to turn at least once
    if (dir[0] == 0 and point.x != end.x) {
        return 1000 + distance;
    }
    if (dir[1] == 0 and point.y != end.y) {
        return 1000 + distance;
    }

    return distance;
}

fn cmp(context: Point, a: *Node, b: *Node) std.math.Order {
    return std.math.order(h(a, context) + a.cost, h(b, context) + b.cost);
}

fn addGoodSeats(node: *Node, good_seats: *std.AutoHashMap(Point, void)) !void {
    try good_seats.put(node.pos.pt, {});
    for (node.prev.items) |prev| {
        try addGoodSeats(prev, good_seats);
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var rows = std.ArrayList(std.ArrayList(u8)).init(allocator);
    defer {
        for (rows.items) |row| {
            row.deinit();
        }
        rows.deinit();
    }

    var lines = std.mem.tokenizeScalar(u8, input, '\n');
    var start = Position{ .pt = Point{ .x = 0, .y = 0 }, .dir = 0 };
    var end = Point{ .x = 0, .y = 0 };

    {
        var y: usize = 0;
        while (lines.next()) |line| : (y += 1) {
            var row = std.ArrayList(u8).init(allocator);

            for (line, 0..) |c, x| {
                if (c == 'S') {
                    start.pt.x = x;
                    start.pt.y = y;
                } else if (c == 'E') {
                    end.x = x;
                    end.y = y;
                }
                try row.append(c);
            }

            try rows.append(row);
        }
    }

    var q = std.PriorityQueue(*Node, Point, cmp).init(allocator, end);
    defer q.deinit();

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();

    const initial = try arena_allocator.create(Node);
    initial.* = Node{ .pos = start, .cost = 0, .prev = std.ArrayList(*Node).init(arena_allocator) };
    try q.add(initial);

    var best: ?usize = null;

    var seen = std.AutoHashMap(Position, *Node).init(allocator);
    defer seen.deinit();

    var good_seats = std.AutoHashMap(Point, void).init(allocator);
    defer good_seats.deinit();

    while (q.removeOrNull()) |node| {
        if (best != null and node.cost > best.?) {
            continue;
        }
        const pos = node.pos;
        const point = pos.pt;
        if (point.x == end.x and point.y == end.y) {
            if (best == null) {
                std.debug.print("Part 1: {}\n", .{node.cost});
            }
            best = node.cost;

            try addGoodSeats(node, &good_seats);
            continue;
        }

        const dir = directions[pos.dir];
        const next_point = Point{ .x = @intCast(@as(i32, @intCast(point.x)) + dir[0]), .y = @intCast(@as(i32, @intCast(point.y)) + dir[1]) };

        if (rows.items[next_point.y].items[next_point.x] != '#') {
            const new_pos = Position{ .pt = next_point, .dir = pos.dir };
            const new_cost = node.cost + 1;
            const seen_node = seen.get(new_pos);

            if (seen_node == null or seen_node.?.cost > new_cost) {
                const new_node = try arena_allocator.create(Node);
                new_node.* = Node{ .pos = new_pos, .cost = new_cost, .prev = std.ArrayList(*Node).init(arena_allocator) };
                try new_node.prev.append(node);
                try q.add(new_node);
                try seen.put(new_pos, new_node);
            } else if (new_cost == seen_node.?.cost) {
                try seen_node.?.prev.append(node);
            }
        }

        for ([_]usize{ (pos.dir + 1) % 4, (pos.dir + 3) % 4 }) |new_dir| {
            const new_pos = Position{ .pt = point, .dir = new_dir };
            const new_cost = node.cost + 1000;
            const seen_node = seen.get(new_pos);

            if (seen_node == null) {
                const new_node = try arena_allocator.create(Node);
                new_node.* = Node{ .pos = new_pos, .cost = new_cost, .prev = std.ArrayList(*Node).init(arena_allocator) };
                try new_node.prev.append(node);
                try q.add(new_node);
                try seen.put(new_pos, new_node);
            } else if (seen_node.?.cost == new_cost) {
                try seen_node.?.prev.append(node);
            }
        }
    }

    std.debug.print("Part 2: {}\n", .{good_seats.count()});

    // for (rows.items, 0..) |row, y| {
    //     for (row.items, 0..) |c, x| {
    //         if (good_seats.get(Point{ .x = x, .y = y }) != null) {
    //             std.debug.print("O", .{});
    //         } else {
    //             std.debug.print("{c}", .{c});
    //         }
    //     }
    //     std.debug.print("\n", .{});
    // }
}
