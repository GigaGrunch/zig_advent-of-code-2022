const std = @import("std");
const input = @embedFile("test-input/day-9.txt");

var alloc: std.mem.Allocator = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    alloc = gpa.allocator();

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        const dir = line[0];
        const count = line[2] - '0';
        std.debug.print("{c} {d}\n", .{dir, count});
    }
}
