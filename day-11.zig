const std = @import("std");
const input = @embedFile("test-input/day-11.txt");
const BigInt = std.math.big.int.Managed;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    var monkeys = std.ArrayList(Monkey).init(alloc);
    defer monkeys.deinit();

    var items = std.ArrayList(Item).init(alloc);
    defer {
        for (items.items) |*item| item.deinit();
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
                .worry_level = try std.math.big.int.Managed.initSet(alloc, item),
                .monkey_index = monkey_index,
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
        var worry_level = &item.worry_level;

        var round: u32 = 1;
        while (round <= 10000) {
            var monkey = &monkeys.items[item.monkey_index];
            monkey.inspections += 1;
            const operation = monkey.operation;

            switch (operation.operator) {
                .Multiply => {
                    switch (operation.b) {
                        .old => try worry_level.mul(worry_level, worry_level),
                        .number => |number| {
                            var big = try BigInt.initSet(alloc, number);
                            defer big.deinit();
                            try worry_level.mul(worry_level, &big);
                        }
                    }
                },
                .Add => {
                    switch (operation.b) {
                        .old => try worry_level.add(worry_level, worry_level),
                        .number => |number| try worry_level.addScalar(worry_level, number),
                    }
                }
            }

            var div = try BigInt.init(alloc);
            defer div.deinit();
            var rem = try BigInt.init(alloc);
            defer rem.deinit();
            var divisor = try BigInt.initSet(alloc, monkey.test_divisor);
            defer divisor.deinit();

            try div.divFloor(&rem, worry_level, &divisor);
            const new_index = if (div.eqZero()) monkey.true_monkey else monkey.false_monkey;
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
    worry_level: BigInt,
    monkey_index: usize,

    pub fn deinit(this: *Item) void {
        this.worry_level.deinit();
    }
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
