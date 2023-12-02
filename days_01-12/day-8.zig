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
        for (line) |height| try row.append(.{.height = height - '0'});
        try rows.append(row);
    }

    const width = rows.items[0].items.len;
    const height = rows.items.len;

    for (rows.items) |row, start_y| {
        for (row.items) |*start_tree, start_x| {
            { // L -> R
                var x = start_x;
                while (x < width - 1):(x += 1) {
                    start_tree.distance_right += 1;
                    if (row.items[x + 1].height >= start_tree.height) break;
                }
            }
            { // R -> L
                var x = start_x;
                while (x > 0):(x -= 1) {
                    start_tree.distance_left += 1;
                    if (row.items[x - 1].height >= start_tree.height) break;
                }
            }
            { // U -> D
                var y = start_y;
                while (y < height - 1):(y += 1) {
                    start_tree.distance_down += 1;
                    if (rows.items[y + 1].items[start_x].height >= start_tree.height) break;
                }
            }
            { // D -> U
                var y = start_y;
                while (y > 0):(y -= 1) {
                    start_tree.distance_up += 1;
                    if (rows.items[y - 1].items[start_x].height >= start_tree.height) break;
                }
            }
        }
    }

    var highScore: u32 = 0;

    for (rows.items) |row| {
        for (row.items) |tree| {
            const score = tree.distance_up * tree.distance_down * tree.distance_left * tree.distance_right;
            highScore = @maximum(highScore, score);
        }
    }

    std.debug.print("highest score is {d}\n", .{highScore});
}

const Tree = struct {
    height: u8,
    distance_up: u32 = 0,
    distance_down: u32 = 0,
    distance_left: u32 = 0,
    distance_right: u32 = 0,
};
