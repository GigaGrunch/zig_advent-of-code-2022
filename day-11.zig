const std = @import("std");
const input = @embedFile("test-input/day-11.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    _ = gpa.allocator();

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        std.debug.assert(std.mem.startsWith(u8, line, "Monkey "));
        _ = lines_it.next().?;
        _ = lines_it.next().?;
        _ = lines_it.next().?;
        _ = lines_it.next().?;
        _ = lines_it.next().?;
    }
}
