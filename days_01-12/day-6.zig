const std = @import("std");
const input = @embedFile("real-input/day-6.txt");

const marker_length = 14;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        var set = std.AutoHashMap(u8, void).init(alloc);
        defer set.deinit();

        var marker: [marker_length]u8 = undefined;

        var i: u32 = 0;
        while (i < marker_length):(i += 1) marker[i] = line[i];

        while (i < line.len):(i += 1) {
            defer set.clearAndFree();
            for (marker) |char| try set.put(char, undefined);
            if (set.count() == marker_length) break;
            marker[i % marker_length] = line[i];
        }

        std.debug.print("count = {d}\n", .{i});
    }
}
