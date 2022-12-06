const std = @import("std");
const input = @embedFile("test-input/day-6.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        var set = std.AutoHashMap(u8, void).init(alloc);
        defer set.deinit();

        var marker: [4]u8 = .{ line[0], line[1], line[2], line[3] };

        var i: u32 = 4;
        while (i < line.len):(i += 1) {
            defer set.clearAndFree();
            for (marker) |char| try set.put(char, undefined);
            if (set.count() == 4) break;
            marker[i % 4] = line[i];
        }

        std.debug.print("count = {d}\n", .{i});
    }
}
