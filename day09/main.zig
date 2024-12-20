const std = @import("std");
const input = @embedFile("input.txt");

const Region = struct {
    size: usize,
    id: ?usize,
};

pub fn part2() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const L = std.DoublyLinkedList(Region);

    var list = L{};
    defer {
        var node = list.first;
        while (node) |n| {
            node = n.next;
            allocator.destroy(n);
        }
    }

    for (input, 0..) |c, i| {
        if (c < '0' or c > '9') {
            break;
        }

        const n: usize = c - '0';

        var id: ?usize = null;
        if (i % 2 == 0) {
            id = i / 2;
        }

        var node = try allocator.create(L.Node);
        node.data.size = n;
        node.data.id = id;

        list.append(node);
    }

    var end = list.last;

    while (true) {
        var to_move = end;
        while (to_move != null and to_move.?.data.id == null) {
            to_move = to_move.?.prev;
        }

        if (to_move == null) {
            break;
        }

        var t = to_move.?;

        var cur = list.first;
        while (cur != null and cur != to_move) {
            const c = cur.?;
            if (c.data.id == null and c.data.size >= t.data.size) {
                var moved_node = try allocator.create(L.Node);
                moved_node.data.size = t.data.size;
                moved_node.data.id = t.data.id;
                list.insertBefore(c, moved_node);
                c.data.size -= t.data.size;
                if (c.data.size == 0) {
                    list.remove(c);
                    allocator.destroy(c);
                }
                t.data.id = null;
                break;
            }
            cur = c.next;
        }

        end = t.prev;
    }

    var total: usize = 0;
    var cur = list.first;
    var pos: usize = 0;
    while (cur) |c| {
        for (0..c.data.size) |_| {
            if (c.data.id) |id| {
                total += pos * id;
            }
            pos += 1;
        }
        cur = c.next;
    }

    std.debug.print("Part 2: {}\n", .{total});
}

pub fn part1() !void {
    var cur: usize = 0;
    var end: usize = input.len - 1;

    var total: usize = 0;

    var pos: usize = 0;
    var filled = true;
    var remaining = input[end] - '0';
    while (cur < end) {
        const c = input[cur];
        if (c < '0' or c > '9') {
            break;
        }

        const n: usize = c - '0';

        for (0..n) |_| {
            if (filled) {
                total += pos * cur / 2;
            } else {
                if (remaining == 0) {
                    end -= 2;
                    remaining = input[end] - '0';
                }
                total += pos * end / 2;
                remaining -= 1;
            }

            pos += 1;
        }

        cur += 1;
        filled = !filled;
    }

    for (0..remaining) |_| {
        total += pos * end / 2;
        pos += 1;
    }

    std.debug.print("Part 1: {}\n", .{total});
}

pub fn main() !void {
    try part1();
    try part2();
}
