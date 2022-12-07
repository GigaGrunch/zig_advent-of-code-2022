const std = @import("std");
const input = @embedFile("test-input/day-7.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    _ = alloc;

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        if (std.mem.eql(u8, line[0..4], "$ cd")) {
            std.debug.print("change dir: {s}\n", .{line});
        }
        else if (std.mem.eql(u8, line[0..4], "$ ls")) {
            std.debug.print("list: {s}\n", .{line});
        }
        else if (line[0] >= '0' and line[0] <= '9') {
            std.debug.print("File: {s}\n", .{line});
        }
        else if (std.mem.eql(u8, line[0..3], "dir")) {
            std.debug.print("Dir: {s}\n", .{line});
        }
        else {
            std.debug.print("Error at {s}\n", .{line});
        }
    }
}

const Dir = struct {
    name: []const u8,
    dirs: std.ArrayList(Dir),
    files: std.ArrayList(File),
};

const File = struct {
    name: []const u8,
    size: u32,
};
