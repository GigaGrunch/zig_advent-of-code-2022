const std = @import("std");
const input = @embedFile("test-input/day-5.txt");

pub fn main() !void {
    var split = std.mem.split(u8, input, "\r\n\r\n");
    const initial_setup = split.next().?;
    const moves = split.next().?;

    std.debug.print("setup:\n{s}\n", .{initial_setup});
    std.debug.print("moves:\n{s}\n", .{moves});
}
