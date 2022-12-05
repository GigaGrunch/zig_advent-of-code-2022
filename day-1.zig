const std = @import("std");
const test_input = @embedFile("test-input/day-1.txt");

pub fn main() void {
    std.debug.print("{s}", .{test_input});
}
