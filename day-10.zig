const std = @import("std");
const input = @embedFile("test-input/day-10.txt");

pub fn main() !void {
    var cycle: i32 = 0;
    var x: i32 = 0;

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        if (std.mem.eql(u8, line[0..4], "addx")) {
            x += 1;
            cycle += 2;
        }
        else if (std.mem.eql(u8, line[0..4], "noop")) {
            cycle += 1;
        }
        else {
            std.debug.print("Unknown instruction: {s}\n", .{line});
        }
    }

    std.debug.print("cycle = {d}, x = {d}\n", .{cycle, x});
}
