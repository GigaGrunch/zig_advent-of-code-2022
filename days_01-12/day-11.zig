const std = @import("std");
const input = @embedFile("real-input/day-11.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    var monkeys = std.ArrayList(Monkey).init(alloc);
    defer monkeys.deinit();

    var items = std.ArrayList(Item).init(alloc);
    defer {
        for (items.items) |*item| item.rems.deinit();
        items.deinit();
    }

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        const monkey_index = monkeys.items.len;

        std.debug.assert(std.mem.startsWith(u8, line, "Monkey "));

        const starting_items_line = lines_it.next().?;
        std.debug.assert(std.mem.startsWith(u8, starting_items_line, "  Starting items: "));
        var starting_items_it = std.mem.tokenize(u8, starting_items_line["  Starting items:".len..], ", ");
        while (starting_items_it.next()) |item_str| {
            const item = try std.fmt.parseInt(i32, item_str, 10);
            try items.append(.{
                .monkey_index = monkey_index,
                .initial_value = item,
                .rems = std.ArrayList(i32).init(alloc),
            });
        }

        const operation_line = lines_it.next().?;
        std.debug.assert(std.mem.startsWith(u8, operation_line, "  Operation: new = old "));
        var operation_it = std.mem.tokenize(u8, operation_line["  Operation: new = old ".len..], " ");
        const op = operation_it.next().?[0];
        const b_string = operation_it.next().?;
        const operation = Operation {
            .operator = switch (op) {
                '+' => .Add,
                '*' => .Multiply,
                else => unreachable
            },
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
            .operation = operation,
            .test_divisor = test_divisor,
            .true_monkey = true_monkey,
            .false_monkey = false_monkey,
        };

        try monkeys.append(monkey);
    }


    for (items.items) |*item| {
        const rem = item.initial_value;
        for (monkeys.items) |monkey| {
            try item.rems.append(@rem(rem, monkey.test_divisor));
        }
    }

    for (items.items) |*item| {
        var round: u32 = 1;
        while (round <= 10000) {
            var monkey = &monkeys.items[item.monkey_index];
            monkey.inspections += 1;
            const operation = monkey.operation;

            switch (operation.operator) {
                .Multiply => {
                    switch (operation.b) {
                        .old => {
                            for (item.rems.items) |*rem, i| {
                                const old = rem.*;
                                rem.* = @rem(rem.*, monkeys.items[i].test_divisor);
                                rem.* *= old;
                                rem.* = @rem(rem.*, monkeys.items[i].test_divisor);
                            }
                        },
                        .number => |number| {
                            for (item.rems.items) |*rem, i| {
                                rem.* = @rem(rem.*, monkeys.items[i].test_divisor);
                                rem.* *= number;
                                rem.* = @rem(rem.*, monkeys.items[i].test_divisor);
                            }
                        },
                    }
                },
                .Add => {
                    switch (operation.b) {
                        .old => {
                            for (item.rems.items) |*rem, i| {
                                rem.* += rem.*;
                                rem.* = @rem(rem.*, monkeys.items[i].test_divisor);
                            }
                        },
                        .number => |number| {
                            for (item.rems.items) |*rem, i| {
                                rem.* += number;
                                rem.* = @rem(rem.*, monkeys.items[i].test_divisor);
                            }
                        },
                    }
                }
            }

            const new_index = if (item.rems.items[item.monkey_index] == 0) monkey.true_monkey else monkey.false_monkey;
            if (new_index < item.monkey_index) round += 1;
            item.monkey_index = new_index;
        }
    }

    var top_inspections = [_]u64 {0} ** 2;
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

const Item = struct {
    monkey_index: usize,
    initial_value: i32,
    rems: std.ArrayList(i32),
};

const Monkey = struct {
    operation: Operation,
    test_divisor: i32,
    true_monkey: usize,
    false_monkey: usize,
    inspections: u64 = 0,
};

const Operation = struct {
    operator: enum { Multiply, Add },
    b: union(enum) { old: void, number: i32 },
};
