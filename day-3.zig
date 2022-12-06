const std = @import("std");
const input = @embedFile("test-input/day-3.txt");

pub fn main() !void {
    var alloc = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = alloc.deinit();

    var total_prio: u32 = 0;

    var rucksack_it = std.mem.tokenize(u8, input, "\n");
    while (rucksack_it.next()) |rucksack_1| {
        const rucksack_2 = rucksack_it.next() orelse unreachable;
        const rucksack_3 = rucksack_it.next() orelse unreachable;

        var counts = std.AutoHashMap(u8, u32).init(alloc.allocator());
        defer counts.deinit();

        const rucksacks = [_][]const u8 { rucksack_1, rucksack_2, rucksack_3 };
        for (rucksacks) |rucksack| {
            var rucksack_set = std.AutoHashMap(u8, void).init(alloc.allocator());
            defer rucksack_set.deinit();

            for (rucksack) |item| try rucksack_set.put(item, undefined);

            var item_it = rucksack_set.keyIterator();
            while (item_it.next()) |item| {
                var count = try counts.getOrPut(item.*);
                count.value_ptr.* = if (count.found_existing) count.value_ptr.* + 1
                                    else 1;

                if (count.value_ptr.* == 3) {
                    const prio: u32 = switch (item.*) {
                        'a'...'z' => item.* - 'a' + 1,
                        'A'...'Z' => item.* - 'A' + 27,
                        else => unreachable
                    };
                    std.debug.print("{c} -> {d}\n", .{item.*, prio});
                    total_prio += prio;
                    break;
                }
            }
        }
    }

    std.debug.print("total prio = {d}\n", .{total_prio});
}
