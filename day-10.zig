const std = @import("std");
const input = @embedFile("test-input/day-10.txt");

var cycle: i32 = 0;
var x: i32 = 1;
var signal_sum: i32 = 0;

pub fn main() !void {
    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    var line_number: usize = 1;
    while (lines_it.next()) |line| {
        nextCycle(line_number);

        if (std.mem.eql(u8, line[0..4], "addx")) {
            const v = try std.fmt.parseInt(i32, line[5..], 10);
            nextCycle(line_number);
            x += v;
        }
        else if (!std.mem.eql(u8, line[0..4], "noop")) {
            unreachable;
        }

        line_number += 1;
    }

    std.debug.print("signal sum = {d}\n", .{signal_sum});
}

fn nextCycle(line_number: usize) void {
    cycle += 1;

    const signal = cycle * x;
    if (cycle == 20 or @rem(cycle - 20, 40) == 0) {
        signal_sum += signal;
        std.debug.print("{d}: cycle = {d}, x = {d}, signal = {d}\n", .{line_number, cycle, x, signal});
    }
}
