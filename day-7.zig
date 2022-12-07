const std = @import("std");
const input = @embedFile("test-input/day-7.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    var root_dir: *Dir = undefined;
    defer root_dir.deinit(alloc);
    var current_dir: ?*Dir = null;

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        if (line.len == 7 and std.mem.eql(u8, line[0..7], "$ cd ..")) {
            current_dir = current_dir.?.parent;
        }
        else if (line.len > 4 and std.mem.eql(u8, line[0..4], "$ cd")) {
            const dir_name = line[5..];

            var dir = try alloc.create(Dir);
            dir.* = Dir {
                .name = dir_name,
                .parent = current_dir,
                .dirs = std.ArrayList(*Dir).init(alloc),
                .files = std.ArrayList(File).init(alloc),
            };
            
            if (std.mem.eql(u8, dir_name, "/")) {
                std.debug.assert(current_dir == null);
                root_dir = dir;
            }
            else {
                try current_dir.?.dirs.append(dir);
            }

            current_dir = dir;
        }
        else if (line.len == 4 and std.mem.eql(u8, line[0..4], "$ ls")) {
            std.debug.print("list: {s}\n", .{line});
        }
        else if (line[0] >= '0' and line[0] <= '9') {
            std.debug.print("File: {s}\n", .{line});
        }
        else if (line.len > 3 and std.mem.eql(u8, line[0..3], "dir")) {
            std.debug.print("Dir: {s}\n", .{line});
        }
        else {
            std.debug.print("Error at {s}\n", .{line});
        }
    }

    printDir(root_dir, 0);
}

fn printDir(dir: *Dir, indent: u32) void {
    var i: u32 = 0;
    while (i < indent * 2):(i += 1) std.debug.print(" ", .{});
    std.debug.print("- {s}\n", .{dir.name});

    for (dir.dirs.items) |subdir| {
        printDir(subdir, indent + 1);
    }
}

const Dir = struct {
    name: []const u8,
    parent: ?*Dir,
    dirs: std.ArrayList(*Dir),
    files: std.ArrayList(File),

    pub fn deinit(this: *Dir, alloc: std.mem.Allocator) void {
        for (this.dirs.items) |dir| {
            dir.deinit(alloc);
        }
        this.dirs.deinit();
        this.files.deinit();

        alloc.destroy(this);
    }
};

const File = struct {
    name: []const u8,
    size: u32,
};
