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

    var pair_index: i32 = 1;
    var sum: i32 = 0;

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
        std.debug.print("\n", .{});

        if ((try areInRightOrder(.{.list = root_1}, .{.list = root_2}, 0)).?) {
            sum += pair_index;
        }

        std.debug.print("\n", .{});

        for (lists.items) |list| {
            list.deinit();
            gpa.allocator().destroy(list);
        }
        lists.clearRetainingCapacity();

        pair_index += 1;
    }

    std.debug.print("final sum: {d}\n", .{sum});
}

fn areInRightOrder(a: Value, b: Value, indent: i32) !?bool {
    switch (a) {
        .number => |number_a| switch (b) {
            .number => |number_b| {
                if (number_a < number_b) {
                    var i: i32 = 0; while (i < indent):(i += 1) { std.debug.print(" ", .{}); }
                    std.debug.print("{d} is smaller than {d} -> right order\n", .{number_a, number_b});
                    return true;
                }
                else if (number_a > number_b) {
                    var i: i32 = 0; while (i < indent):(i += 1) { std.debug.print(" ", .{}); }
                    std.debug.print("{d} is larger than {d} -> wrong order\n", .{number_a, number_b});
                    return false;
                }
                else {
                    var i: i32 = 0; while (i < indent):(i += 1) { std.debug.print(" ", .{}); }
                    std.debug.print("{d} is equal to {d} -> undecided\n", .{number_a, number_b});
                    return null;
                }
            },
            .list => {
                var list_a = try lists.allocator.create(List);
                list_a.* = List.init(lists.allocator);
                try lists.append(list_a);
                try list_a.append(.{.number = number_a});
                return try areInRightOrder(.{.list = list_a}, b, indent + 2);
            },
        },
        .list => |list_a| switch (b) {
            .number => |number_b| {
                var list_b = try lists.allocator.create(List);
                list_b.* = List.init(lists.allocator);
                try lists.append(list_b);
                try list_b.append(.{.number = number_b});
                return try areInRightOrder(a, .{.list = list_b}, indent + 2);
            },
            .list => |list_b| {
                {
                    var i: i32 = 0; while (i < indent):(i += 1) { std.debug.print(" ", .{}); }
                    std.debug.print("checking lists...\n", .{});
                }

                var index: usize = 0;
                while (index < list_a.items.len) : (index += 1) {
                    if (index >= list_b.items.len) {
                        var i: i32 = 0; while (i < indent + 2):(i += 1) { std.debug.print(" ", .{}); }
                        std.debug.print("right list ran out of elements -> wrong order\n", .{});
                        return false;
                    }

                    if (try areInRightOrder(list_a.items[index], list_b.items[index], indent + 4)) |right_order| {
                        return right_order;
                    }
                }

                if (index < list_b.items.len) {
                    var i: i32 = 0; while (i < indent + 2):(i += 1) { std.debug.print(" ", .{}); }
                    std.debug.print("left list ran out of elements -> right order\n", .{});
                    return true;
                }

                {
                    var i: i32 = 0; while (i < indent + 2):(i += 1) { std.debug.print(" ", .{}); }
                    std.debug.print("lists are equal -> undecided\n", .{});
                    return null;
                }
            },
        },
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
