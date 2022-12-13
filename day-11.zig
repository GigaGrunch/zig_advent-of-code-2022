const std = @import("std");
const input = @embedFile("real-input/day-11.txt");

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

        const true_line = lines_it.next().?;
        std.debug.assert(std.mem.startsWith(u8, true_line, "    If true: throw to monkey "));
        const true_monkey = try std.fmt.parseInt(usize, true_line["    If true: throw to monkey ".len..], 10);

        const false_line = lines_it.next().?;
        std.debug.assert(std.mem.startsWith(u8, false_line, "    If false: throw to monkey "));
        const false_monkey = try std.fmt.parseInt(usize, false_line["    If false: throw to monkey ".len..], 10);

        var monkey = Monkey {
            .items = starting_items,
            .operation = operation,
            .test_divisor = test_divisor,
            .true_monkey = true_monkey,
            .false_monkey = false_monkey,
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
            .number => |number| std.debug.print("{d} ", .{number}),
        }
        std.debug.print("{c} ", .{monkey.operation.operator});
        switch (monkey.operation.b) {
            .old => std.debug.print("old ", .{}),
            .number => |number| std.debug.print("{d} ", .{number}),
        }
        std.debug.print("\n", .{});

        std.debug.print("  Test: divisible by {d}\n", .{monkey.test_divisor});
        std.debug.print("    If true: throw to monkey {d}\n", .{monkey.true_monkey});
        std.debug.print("    If false: throw to monkey {d}\n", .{monkey.false_monkey});

        std.debug.print("\n", .{});
    }

    var round: i32 = 1;
    while (round <= 20):(round += 1) {
        for (monkeys.items) |*monkey, i| {
            _ = i;
            // std.debug.print("Monkey {d}:\n", .{i});
            std.mem.reverse(i32, monkey.items.items);
            while (monkey.items.items.len > 0) {
                monkey.inspections += 1;
                var item = monkey.items.pop();
                // std.debug.print("  Monkey inspects an item with a worry level of {d}.\n", .{item});
                const b = switch (monkey.operation.b) {
                    .old => item,
                    .number => |number| number,
                };
                switch (monkey.operation.operator) {
                    '+' => {
                        item += b;
                        // std.debug.print("    Worry level increases by {d} to {d}.\n", .{b, item});
                    },
                    '*' => {
                        item *= b;
                        // std.debug.print("    Worry level is multiplied by {d} to {d}.\n", .{b, item});
                    },
                    else => unreachable
                }
                
                item = @divFloor(item, 3);
                // std.debug.print("    Monkey gets bored with item. Worry level is divided by 30 to {d}.\n", .{item});
                if (@rem(item, monkey.test_divisor) == 0) {
                    // std.debug.print("    Current worry level is divisible by {d}.\n", .{monkey.test_divisor});
                    // std.debug.print("    Item with worry level {d} is thrown to monkey {d}.\n", .{item, monkey.true_monkey});
                    try monkeys.items[monkey.true_monkey].items.append(item);
                }
                else {
                    // std.debug.print("    Current worry level is not divisible by {d}.\n", .{monkey.test_divisor});
                    // std.debug.print("    Item with worry level {d} is thrown to monkey {d}.\n", .{item, monkey.false_monkey});
                    try monkeys.items[monkey.false_monkey].items.append(item);
                }
            }
        }

        for (monkeys.items) |monkey, i| {
            std.debug.print("Monkey {d}: ", .{i});
            for (monkey.items.items) |item| std.debug.print("{d}, ", .{item});
            std.debug.print("\n", .{});
        }
        std.debug.print("\n", .{});
    }

    var top_inspections = [_]i32 {0} ** 2;
    for (monkeys.items) |monkey, i| {
        std.debug.print("Monkey {d} inspected items {d} times.\n", .{i, monkey.inspections});

        if (monkey.inspections > top_inspections[0]) {
            top_inspections[1] = top_inspections[0];
            top_inspections[0] = monkey.inspections;
        }
        else if (monkey.inspections > top_inspections[1]) {
            top_inspections[1] = monkey.inspections;
        }
    }

    std.debug.print("Level of monkey business: {d} * {d} = {d}\n", .{top_inspections[0], top_inspections[1], top_inspections[0] * top_inspections[1]});
}

const Monkey = struct {
    items: std.ArrayList(i32),
    operation: Operation,
    test_divisor: i32,
    true_monkey: usize,
    false_monkey: usize,
    inspections: i32 = 0,

    pub fn deinit(monkey: *Monkey) void {
        monkey.items.deinit();
    }
};

const Operation = struct {
    operator: u8,
    a: union(enum) { old: void, number: i32 },
    b: union(enum) { old: void, number: i32 },
};
