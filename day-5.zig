const std = @import("std");
const input = @embedFile("test-input/day-5.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var split = std.mem.split(u8, input, "\r\n\r\n");
    const initial_setup = split.next().?;
    const moves = split.next().?;

    std.debug.print("setup:\n{s}\n", .{initial_setup});
    std.debug.print("moves:\n{s}\n", .{moves});

    var stacks = std.ArrayList(std.ArrayList(u8)).init(alloc);
    defer {
        for (stacks.items) |stack| stack.deinit();
        stacks.deinit();
    }

    {
        var setup_lines_it = std.mem.tokenize(u8, initial_setup, "\r\n");
        var last_line: []const u8 = undefined;
        while (setup_lines_it.next()) |line| {
            last_line = line;
        }
        var stack_number_it = std.mem.tokenize(u8, last_line, " ");
        while (stack_number_it.next()) |_| {
            try stacks.append(std.ArrayList(u8).init(alloc));
        }
    }

    std.debug.print("{d} stacks\n", .{stacks.items.len});
}
