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
        std.debug.assert(std.mem.startsWith(u8, starting_items_line, "  Starting items: "));
        var starting_items = std.ArrayList(i32).init(alloc);
        var starting_items_it = std.mem.tokenize(u8, starting_items_line["  Starting items:".len..], ", ");
        while (starting_items_it.next()) |item| try starting_items.append(try std.fmt.parseInt(i32, item, 10));

        const operation_line = lines_it.next().?;
        std.debug.assert(std.mem.startsWith(u8, operation_line, "  Operation: new = "));
        var operation_it = std.mem.tokenize(u8, operation_line["  Operation: new = ".len..], " ");
        const a_string = operation_it.next().?;
        const op = operation_it.next().?[0];
        const b_string = operation_it.next().?;
        const operation = Operation {
            .operator = op,
            .a = if (std.mem.eql(u8, a_string, "old")) .{.old = undefined} else .{.number = try std.fmt.parseInt(i32, a_string, 10)},
            .b = if (std.mem.eql(u8, b_string, "old")) .{.old = undefined} else .{.number = try std.fmt.parseInt(i32, b_string, 10)},
        };

        const test_line = lines_it.next().?;
        std.debug.assert(std.mem.startsWith(u8, test_line, "  Test: divisible by "));
        const test_divisor = try std.fmt.parseInt(i32, test_line["  Test: divisible by ".len..], 10);

        _ = lines_it.next().?;
        _ = lines_it.next().?;

        var monkey = Monkey {
            .items = starting_items,
            .operation = operation,
            .test_divisor = test_divisor,
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

        std.debug.print("  Operation: new = ", .{});
        switch (monkey.operation.a) {
            .old => std.debug.print("old ", .{}),
            .number => |a| std.debug.print("{d} ", .{a}),
        }
        std.debug.print("{c} ", .{monkey.operation.operator});
        switch (monkey.operation.b) {
            .old => std.debug.print("old ", .{}),
            .number => |b| std.debug.print("{d} ", .{b}),
        }
        std.debug.print("\n", .{});

        std.debug.print("  Test: divisible by {d}\n", .{monkey.test_divisor});

        std.debug.print("\n", .{});
    }
}

const Monkey = struct {
    items: std.ArrayList(i32),
    operation: Operation,
    test_divisor: i32,

    pub fn deinit(monkey: *Monkey) void {
        monkey.items.deinit();
    }
};

const Operation = struct {
    operator: u8,
    a: union(enum) { old: void, number: i32 },
    b: union(enum) { old: void, number: i32 },
};
