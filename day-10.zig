const std = @import("std");
const input = @embedFile("test-input/day-10.txt");

var cycle: u32 = 0;
var x: i32 = 1;

pub fn main() !void {
    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        nextCycle();

        if (std.mem.eql(u8, line[0..4], "addx")) {
            const v = try std.fmt.parseInt(i32, line[5..], 10);
            x += v;
            nextCycle();
        }
        else if (!std.mem.eql(u8, line[0..4], "noop")) {
            unreachable;
        }
    }
}

fn nextCycle() void {
    cycle += 1;
    if (cycle == 20 or (cycle > 20 and (cycle - 20) % 40 == 0)) {
        std.debug.print("cycle = {d}, x = {d}\n", .{cycle, x});
    }
}
