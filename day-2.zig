const std = @import("std");
const input = @embedFile("test-input/day-2.txt");

pub fn main() !void {
    var round_it = std.mem.tokenize(u8, input, "\n");
    while (round_it.next()) |round| {
        var move_it = std.mem.tokenize(u8, round, " ");
        const their_move = move_it.next() orelse unreachable;
        const my_move = move_it.next() orelse unreachable;

        std.debug.print("{s} -> {s}\n", .{their_move, my_move});
    }
}
