const std = @import("std");
const test_input = @embedFile("test-input/day-1.txt");

pub fn main() !void {
    var max_calories: u32 = 0;

    var elf_it = std.mem.split(u8, test_input, "\n\n");
    while (elf_it.next()) |elf| {
        std.debug.print("elf: ", .{});
        var total_calories: u32 = 0;
        var item_it = std.mem.split(u8, elf, "\n");
        while (item_it.next()) |calories| {
            if (calories.len == 0) continue;

            std.debug.print("{s} ", .{calories});
            total_calories += try std.fmt.parseInt(u32, calories, 10);
        }
        std.debug.print("= {d}\n", .{total_calories});

        max_calories = @maximum(max_calories, total_calories);
    }

    std.debug.print("max calories = {d}\n", .{max_calories});
}
