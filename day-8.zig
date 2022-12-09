const std = @import("std");
const input = @embedFile("test-input/day-8.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    var rows = std.ArrayList([]const u8).init(alloc);
    defer rows.deinit();

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| try rows.append(line);

    for (rows.items) |row| {
        std.debug.print("{s}\n", .{row});
    }
}
