const std = @import("std");

var lists: std.ArrayList(*List) = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var args = try std.process.argsAlloc(gpa.allocator());
    defer std.process.argsFree(gpa.allocator(), args);

    if (args.len != 2) {
        std.debug.print("Pass one input file.\n", .{});
        return;
    }

    const input_file = args[1];
    std.debug.print("reading '{s}'\n", .{input_file});

    const text = try std.fs.cwd().readFileAlloc(gpa.allocator(), input_file, 100000);
    defer gpa.allocator().free(text);

    std.debug.print("file has {d} bytes\n", .{text.len});

    lists = std.ArrayList(*List).init(gpa.allocator());
    defer lists.deinit();

    var lines = std.mem.tokenizeAny(u8, text, "\r\n");
    while (lines.next()) |first_line| {
        var root_1: *List = undefined;
        {
            var parts = ValueIterator.init(first_line);
            std.debug.assert(std.mem.eql(u8, parts.next().?, "["));
            root_1 = try parseList(&parts);
        }
        var root_2: *List = undefined;
        {
            const second_line = lines.next().?;

            var parts = ValueIterator.init(second_line);
            std.debug.assert(std.mem.eql(u8, parts.next().?, "["));
            root_2 = try parseList(&parts);
        }

        printList(root_1);
        std.debug.print("\n", .{});
        printList(root_2);
        std.debug.print("\n\n", .{});

        for (lists.items) |list| {
            list.deinit();
            gpa.allocator().destroy(list);
        }
        lists.clearRetainingCapacity();
    }
}

fn parseList(parts: *ValueIterator) !*List {
    var list = try lists.allocator.create(List);
    list.* = List.init(lists.allocator);
    try lists.append(list);

    while (parts.next()) |part| {
        if (std.mem.eql(u8, part, "[")) {
            try list.append(.{.list = try parseList(parts)});
        } else if (std.mem.eql(u8, part, "]")) {
            return list;
        } else {
            try list.append(.{.number = try std.fmt.parseInt(i32, part, 10)});
        }
    }

    return list;
}

fn deinitList(list: *List) void {
    for (list.items) |value| {
        switch (value) {
            .number => { },
            .list => |sub_list| deinitList(sub_list),
        }
    }

    list.deinit();
}

fn printList(list: *List) void {
    std.debug.print("[", .{});
    for (list.items) |value| {
        std.debug.print(" ", .{});
        switch (value) {
            .number => |number| std.debug.print("{d}", .{number}),
            .list => |sub_list| printList(sub_list),
        }
        std.debug.print(" ", .{});
    }
    std.debug.print("]", .{});
}

const ValueIterator = struct {
    string: []const u8,

    pub fn init(string: []const u8) ValueIterator {
        return .{ .string = string };
    }

    pub fn next(self: *ValueIterator) ?[]const u8 {
        if (self.string.len == 0) return null;
        while (self.string[0] == ',') self.string = self.string[1..];
        if (self.string[0] == '[') {
            self.string = self.string[1..];
            return "[";
        }
        if (self.string[0] == ']') {
            self.string = self.string[1..];
            return "]";
        }
        
        const end_index = std.mem.indexOfAny(u8, self.string, ",[]") orelse self.string.len;
        defer self.string = self.string[end_index..];
        return self.string[0..end_index];
    }
};

const Value = union(enum) {
    number: i32,
    list: *List,
};

const List = std.ArrayList(Value);
