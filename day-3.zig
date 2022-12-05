const std = @import("std");
const input = @embedFile("test-input/day-3.txt");

pub fn main() !void {
    var rucksack_it = std.mem.tokenize(u8, input, "\n");
    while (rucksack_it.next()) |rucksack| {
        const compartment_1 = rucksack[0..rucksack.len/2];
        const compartment_2 = rucksack[rucksack.len/2..];
        std.debug.print("{s} | {s}\n", .{compartment_1, compartment_2});
    }
}
