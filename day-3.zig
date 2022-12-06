const std = @import("std");
const input = @embedFile("test-input/day-3.txt");

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    var set = std.AutoHashMap(u8, void).init(alloc.allocator());

    var rucksack_it = std.mem.tokenize(u8, input, "\n");
    while (rucksack_it.next()) |rucksack| {
        const compartment_1 = rucksack[0..rucksack.len/2];
        const compartment_2 = rucksack[rucksack.len/2..];

        for (compartment_1) |item| try set.put(item, undefined);
        for (compartment_2) |item| {
            if (set.contains(item)) {
                const prio: u32 = switch (item) {
                    'a'...'z' => item - 'a' + 1,
                    'A'...'Z' => item - 'A' + 27,
                    else => unreachable
                };
                std.debug.print("{c} -> {d}\n", .{item, prio});
                break;
            }
        }

        set.clearAndFree();
    }
}
