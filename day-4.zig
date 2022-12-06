const std = @import("std");
const input = @embedFile("test-input/day-4.txt");

pub fn main() !void {
    var pair_it = std.mem.tokenize(u8, input, "\r\n");
    while (pair_it.next()) |pair| {
        var assign_it = std.mem.tokenize(u8, pair, ",");
        const assign_1 = assign_it.next().?;
        const assign_2 = assign_it.next().?;

        const range_1 = try getRange(assign_1);
        const range_2 = try getRange(assign_2);

        std.debug.print("{}..{}, {}..{}\n", .{range_1.min, range_1.max, range_2.min, range_2.max});
    }
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
