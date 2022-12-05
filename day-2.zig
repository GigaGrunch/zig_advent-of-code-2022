const std = @import("std");
const input = @embedFile("test-input/day-2.txt");

pub fn main() !void {
    var round_it = std.mem.tokenize(u8, input, "\n");
    while (round_it.next()) |round| {
        std.debug.print("{s}\n", .{round});
    }
}
