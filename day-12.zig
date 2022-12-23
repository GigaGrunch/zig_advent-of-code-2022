const std = @import("std");
const input = @embedFile("test-input/day-12.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    var rows = std.ArrayList(std.ArrayList(u8)).init(alloc);
    defer {
        for (rows.items) |*row| row.deinit();
        rows.deinit();
    }

    var goal_pos: Pos = undefined;
    var start_pos: Pos = undefined;

    var lines_it = std.mem.tokenize(u8, input, "\n\r");
    var y: usize = 0;
    while (lines_it.next()) |line| {
        try rows.append(std.ArrayList(u8).init(alloc));
        for (line) |char, x| {
            switch (char) {
                'S' => {
                    try rows.items[y].append('a');
                    start_pos = .{ .x = x, .y = y };
                },
                'E' => {
                    try rows.items[y].append('z');
                    goal_pos = .{ .x = x, .y = y };
                },
                else => try rows.items[y].append(char)
            }
        }
        y += 1;
    }

    for (rows.items) |row| {
        std.debug.print("{s}\n", .{row.items});
    }
}

const Pos = struct {
    x: usize,
    y: usize,
};
