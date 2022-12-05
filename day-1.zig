const std = @import("std");
const test_input = @embedFile("test-input/day-1.txt");

pub fn main() void {
    var elf_it = std.mem.split(u8, test_input, "\n\n");
    while (elf_it.next()) |elf| {
        std.debug.print("elf: ", .{});
        var item_it = std.mem.split(u8, elf, "\n");
        while (item_it.next()) |item| {
            std.debug.print("{s} ", .{item});
        }
        std.debug.print("\n", .{});
    }
}
