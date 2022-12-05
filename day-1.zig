const std = @import("std");
const input = @embedFile("test-input/day-1.txt");

pub fn main() !void {
    var max_calories = [_]u32 {0} ** 3;

    var elf_it = std.mem.split(u8, input, "\n\n");
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

        if (total_calories > max_calories[0]) {
            max_calories[2] = max_calories[1];
            max_calories[1] = max_calories[0];
            max_calories[0] = total_calories;
        }
        else if (total_calories > max_calories[1]) {
            max_calories[2] = max_calories[1];
            max_calories[1] = total_calories;
        }
        else if (total_calories > max_calories[2]) {
            max_calories[2] = total_calories;
        }
    }

    const total_max_calories = max_calories[0] + max_calories[1] + max_calories[2];

    std.debug.print("max calories = {d} + {d} + {d} = {d}\n",
        .{max_calories[0], max_calories[1], max_calories[2], total_max_calories});
}
