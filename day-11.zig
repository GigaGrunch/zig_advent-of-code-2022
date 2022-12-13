const std = @import("std");
const input = @embedFile("test-input/day-11.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    var monkeys = std.ArrayList(Monkey).init(alloc);
    defer {
        for (monkeys.items) |*monkey| monkey.deinit();
        monkeys.deinit();
    }

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        std.debug.assert(std.mem.startsWith(u8, line, "Monkey "));

        const starting_items_line = lines_it.next().?;
        var starting_items = std.ArrayList(i32).init(alloc);
        var starting_items_it = std.mem.tokenize(u8, starting_items_line["  Starting items:".len..], ", ");
        while (starting_items_it.next()) |item| try starting_items.append(try std.fmt.parseInt(i32, item, 10));

        _ = lines_it.next().?;
        _ = lines_it.next().?;
        _ = lines_it.next().?;
        _ = lines_it.next().?;

        var monkey = Monkey {
            .items = starting_items,
        };

        try monkeys.append(monkey);
    }

    for (monkeys.items) |monkey, i| {
        std.debug.print("Monkey {d}:", .{i});

        std.debug.print("Starting items: ", .{});
        for (monkey.items.items) |item| {
            std.debug.print("{d}, ", .{item});
        }
        std.debug.print("\n", .{});
    }
}

const Monkey = struct {
    items: std.ArrayList(i32),

    pub fn deinit(monkey: *Monkey) void {
        monkey.items.deinit();
    }
};
