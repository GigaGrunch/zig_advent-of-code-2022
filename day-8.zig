const std = @import("std");
const input = @embedFile("real-input/day-8.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    var rows = std.ArrayList(std.ArrayList(Tree)).init(alloc);
    defer {
        for (rows.items) |row| row.deinit();
        rows.deinit();
    }

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        var row = std.ArrayList(Tree).init(alloc);
        for (line) |height| try row.append(.{
            .height = height - '0',
            .visible = false,
        });
        try rows.append(row);
    }

    const width = rows.items[0].items.len;
    const height = rows.items.len;

    for (rows.items) |row| {
        { // left to right
            var maxHeight: i32 = -1;
            for (row.items) |*tree| {
                if (tree.height > maxHeight) {
                    tree.visible = true;
                    maxHeight = tree.height;
                }
            }
        }
        { // right to left
            var maxHeight: i32 = -1;
            var x: usize = width - 1;
            while (true):(x -= 1) {
                const tree = &row.items[x];
                if (tree.height > maxHeight) {
                    tree.visible = true;
                    maxHeight = tree.height;
                }
                if (x == 0) break;
            }
        }
    }
    { // top to bottom
        var x: usize = 0;
        while (x < width):(x += 1) {
            var maxHeight: i32 = -1;
            for (rows.items) |row| {
                const tree = &row.items[x];
                if (tree.height > maxHeight) {
                    tree.visible = true;
                    maxHeight = tree.height;
                }
            }
        }
    }
    { // bottom to top
        var x: usize = 0;
        while (x < width):(x += 1) {
            var maxHeight: i32 = -1;
            var y: usize = height - 1;
            while (y >= 0):(y -= 1) {
                const tree = &rows.items[y].items[x];
                if (tree.height > maxHeight) {
                    tree.visible = true;
                    maxHeight = tree.height;
                }
                if (y == 0) break;
            }
        }
    }

    var visibleCount: u32 = 0;
    for (rows.items) |row| {
        for (row.items) |tree| {
            if (tree.visible) {
                visibleCount += 1;
                std.debug.print("{d}*", .{tree.height});
            }
            else {
                std.debug.print("{d} ", .{tree.height});
            }
        }
        std.debug.print("\n", .{});
    }

    std.debug.print("{d} trees are visible.\n", .{visibleCount});
}

const Tree = struct {
    height: u8,
    visible: bool,
};
