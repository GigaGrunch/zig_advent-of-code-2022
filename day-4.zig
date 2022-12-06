const std = @import("std");
const input = @embedFile("real-input/day-4.txt");

pub fn main() !void {
    var count: u32 = 0;

    var pair_it = std.mem.tokenize(u8, input, "\r\n");
    while (pair_it.next()) |pair| {
        var assign_it = std.mem.tokenize(u8, pair, ",");
        const assign_1 = assign_it.next().?;
        const assign_2 = assign_it.next().?;

        const range_1 = try getRange(assign_1);
        const range_2 = try getRange(assign_2);

        if ((range_1.min >= range_2.min and range_1.max <= range_2.max) or
            (range_2.min >= range_1.min and range_2.max <= range_1.max)) {
            count += 1;
        }
    }

    std.debug.print("count = {d}\n", .{count});
}

fn getRange(assignment: []const u8) !struct { min: u32, max: u32 } {
    var it = std.mem.tokenize(u8, assignment, "-");
    const min = it.next().?;
    const max = it.next().?;

    return .{
        .min = try std.fmt.parseInt(u32, min, 10),
        .max = try std.fmt.parseInt(u32, max, 10),
    };
}
