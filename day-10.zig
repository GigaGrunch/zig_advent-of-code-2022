const std = @import("std");
const input = @embedFile("test-input/day-10.txt");

var cycle: i32 = 0;
var x: i32 = 1;

pub fn main() !void {
    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        const v: ?i32 = if (std.mem.eql(u8, line[0..4], "addx"))
            try std.fmt.parseInt(i32, line[5..], 10)
            else null;

        nextCycle();

        if (v) |value| {
            nextCycle();
            x += value;
        }
    }
}

fn nextCycle() void {
    const sprite_pixels = [_]i32 { x-1, x, x+1 };

    var pixel: u8 = '.';

    for (sprite_pixels) |p| {
        if (@rem(cycle, 40) == p) {
            pixel = '#';
        }
    }

    std.debug.print("{c}", .{pixel});

    cycle += 1;

    if (@rem(cycle, 40) == 0) {
        std.debug.print("\n", .{});
    }
}
