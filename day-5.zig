const std = @import("std");
const input = @embedFile("test-input/day-5.txt");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var alloc = gpa.allocator();
    defer _ = gpa.deinit();

    var split = std.mem.split(u8, input, "\r\n\r\n");
    const initial_setup = split.next().?;
    const moves = split.next().?;

    var stacks = std.ArrayList(std.ArrayList(u8)).init(alloc);
    defer {
        for (stacks.items) |stack| stack.deinit();
        stacks.deinit();
    }

    var stack_height: u32 = 0;

    {
        var setup_lines_it = std.mem.tokenize(u8, initial_setup, "\r\n");
        var last_line: []const u8 = undefined;
        while (setup_lines_it.next()) |line| {
            stack_height += 1;
            last_line = line;
        }
        stack_height -= 1;
        var stack_number_it = std.mem.tokenize(u8, last_line, " ");
        while (stack_number_it.next()) |_| {
            try stacks.append(std.ArrayList(u8).init(alloc));
        }
    }
    {
        var i: u32 = 0;
        var setup_lines_it = std.mem.tokenize(u8, initial_setup, "\r\n");
        while (i < stack_height):(i += 1) {
            const line = setup_lines_it.next().?;

            var stack_index: usize = 0;
            while (stack_index < stacks.items.len):(stack_index += 1) {
                const crate_pos = stack_index * 4 + 1;
                if (line[crate_pos] != ' ') {
                    try stacks.items[stack_index].append(line[crate_pos]);
                }
            }
        }
    }

    for (stacks.items) |stack| std.mem.reverse(u8, stack.items);

    var move_it = std.mem.tokenize(u8, moves, "\r\n");
    while (move_it.next()) |move| {
        printStacks(stacks);

        var part_it = std.mem.tokenize(u8, move, "move from to");
        const count = try std.fmt.parseInt(u32, part_it.next().?, 10);
        const from = try std.fmt.parseInt(u32, part_it.next().?, 10);
        const to = try std.fmt.parseInt(u32, part_it.next().?, 10);
        std.debug.print("{d}x {d} -> {d}\n", .{count, from, to});

        var crane = std.ArrayList(u8).init(alloc);
        defer crane.deinit();

        var i: u32 = 0;
        while (i < count):(i += 1) {
            const crate = stacks.items[from-1].pop();
            try crane.append(crate);
        }

        std.mem.reverse(u8, crane.items);
        try stacks.items[to-1].appendSlice(crane.items);
    }

    printStacks(stacks);

    std.debug.print("result: ", .{});
    for (stacks.items) |stack| std.debug.print("{c}", .{stack.items[stack.items.len - 1]});
    std.debug.print("\n", .{});
}

fn printStacks(stacks: std.ArrayList(std.ArrayList(u8))) void {
    for (stacks.items) |stack, i| {
        std.debug.print("stack {}: ", .{i+1});
        for (stack.items) |crate| std.debug.print("{c}", .{crate});
        std.debug.print("\n", .{});
    }
}
