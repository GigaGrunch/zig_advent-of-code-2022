const std = @import("std");
const input = @embedFile("real-input/day-10.txt");

var cycle: i32 = 0;
var x: i32 = 1;

pub fn main() !void {
    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        nextCycle();

        if (std.mem.eql(u8, line[0..4], "addx")) {
            const v = try std.fmt.parseInt(i32, line[5..], 10);
            nextCycle();
            x += v;
        }
        else if (!std.mem.eql(u8, line[0..4], "noop")) {
            unreachable;
        }
    }
}

fn nextCycle() void {
    cycle += 1;

    std.debug.print(".", .{});

    if (@rem(cycle, 40) == 0) {
        std.debug.print("\n", .{});
    }
}
