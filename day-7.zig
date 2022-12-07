const std = @import("std");
const input = @embedFile("real-input/day-7.txt");

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
                .size = 0,
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
        }
        else if (line[0] >= '0' and line[0] <= '9') {
            var file_it = std.mem.tokenize(u8, line, " ");
            const size = try std.fmt.parseInt(u32, file_it.next().?, 10);
            current_dir.?.addSize(size);
        }
        else if (line.len > 3 and std.mem.eql(u8, line[0..3], "dir")) {
        }
        else {
        }
    }

    printDir(root_dir, 0);

    var result = std.ArrayList(*Dir).init(alloc);
    defer result.deinit();

    const disk_space: u32 = 70000000;
    const required_space: u32 = 30000000;
    const used_space = root_dir.size;
    const unused_space = disk_space - used_space;

    try findDirs(root_dir, required_space - unused_space, &result);

    var smallest: *Dir = result.items[0];

    std.debug.print("Dirs larger than {d}:\n", .{required_space - unused_space});
    for (result.items) |dir| {
        std.debug.print("{s} ({d})\n", .{dir.name, dir.size});
        if (dir.size < smallest.size) smallest = dir;
    }

    std.debug.print("{s} is the smallest ({d})\n", .{smallest.name, smallest.size});
}

fn printDir(root: *Dir, indent: u32) void {
    var i: u32 = 0;
    while (i < indent * 2):(i += 1) std.debug.print(" ", .{});
    std.debug.print("- {s} ({d})\n", .{root.name, root.size});

    for (root.dirs.items) |dir| {
        printDir(dir, indent + 1);
    }
}

fn findDirs(root: *Dir, min_size: u32, result: *std.ArrayList(*Dir)) !void {
    if (root.size >= min_size) try result.append(root);

    for (root.dirs.items) |dir| {
        try findDirs(dir, min_size, result);
    }
}

const Dir = struct {
    name: []const u8,
    parent: ?*Dir,
    size: u32,
    dirs: std.ArrayList(*Dir),
    files: std.ArrayList(File),

    pub fn addSize(this: *Dir, size: u32) void {
        this.size += size;
        if (this.parent) |p| p.addSize(size);
    }

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
