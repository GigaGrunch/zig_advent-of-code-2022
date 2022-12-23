const std = @import("std");
const input = @embedFile("test-input/day-12.txt");

var width: usize = undefined;
var height: usize = undefined;
var rows: std.ArrayList(std.ArrayList(u8)) = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var alloc = gpa.allocator();

    rows = std.ArrayList(std.ArrayList(u8)).init(alloc);
    defer {
        for (rows.items) |*row| row.deinit();
        rows.deinit();
    }

    var goal_pos: Pos = undefined;
    var start_positions = std.ArrayList(Pos).init(alloc);
    defer start_positions.deinit();

    var lines_it = std.mem.tokenize(u8, input, "\n\r");
    var y: usize = 0;
    while (lines_it.next()) |line| {
        try rows.append(std.ArrayList(u8).init(alloc));
        for (line) |char, x| {
            switch (char) {
                'S' => {
                    try rows.items[y].append('a');
                    try start_positions.append(.{ .x = x, .y = y });
                },
                'E' => {
                    try rows.items[y].append('z');
                    goal_pos = .{ .x = x, .y = y };
                },
                'a' => {
                    try rows.items[y].append(char);
                    try start_positions.append(.{ .x = x, .y = y });
                },
                else => try rows.items[y].append(char)
            }
            width = x + 1;
        }
        height = y + 1;
        y += 1;
    }

    for (rows.items) |row| {
        std.debug.print("{s}\n", .{row.items});
    }

    var visited = std.AutoHashMap(Pos, u32).init(alloc);
    defer visited.deinit();

    var shortest: u32 = 99999;
    for (start_positions.items) |start_pos| {
        var frontier = std.ArrayList(Step).init(alloc);
        defer frontier.deinit();

        try visited.put(start_pos, 0);
        if (leftOf(start_pos)) |left| try frontier.append(left);
        if (rightOf(start_pos)) |right| try frontier.append(right);
        if (bottomOf(start_pos)) |bottom| try frontier.append(bottom);
        if (topOf(start_pos)) |top| try frontier.append(top);
        while (frontier.items.len > 0) {
            const step = frontier.pop();
            const step_count = visited.get(step.from).? + 1;
            if (visited.get(step.to)) |previous_step_count| {
                if (step_count >= previous_step_count) continue;
            }
            try visited.put(step.to, step_count);

            if (leftOf(step.to)) |left| try frontier.append(left);
            if (rightOf(step.to)) |right| try frontier.append(right);
            if (bottomOf(step.to)) |bottom| try frontier.append(bottom);
            if (topOf(step.to)) |top| try frontier.append(top);
        }

        if (visited.get(goal_pos)) |steps| {
            std.debug.print("{d} steps\n", .{steps});
            if (steps < shortest) shortest = steps;
        }
    }

    std.debug.print("shortest = {d}\n", .{shortest});
}

fn canBeTraversed(from: Pos, to: Pos) bool {
    return rows.items[from.y].items[from.x] + 1 >= rows.items[to.y].items[to.x];
}

fn leftOf(from: Pos) ?Step {
    if (from.x == 0) return null;
    const to = Pos {
        .x = from.x - 1,
        .y = from.y,
    };
    return if (!canBeTraversed(from, to)) null else .{
        .from = from,
        .to = to,
    };
}

fn rightOf(from: Pos) ?Step {
    if (from.x == width - 1) return null;
    const to = Pos {
        .x = from.x + 1,
        .y = from.y,
    };
    return if (!canBeTraversed(from, to)) null else .{
        .from = from,
        .to = to,
    };
}

fn topOf(from: Pos) ?Step {
    if (from.y == 0) return null;
    const to = Pos {
        .x = from.x,
        .y = from.y - 1,
    };
    return if (!canBeTraversed(from, to)) null else .{
        .from = from,
        .to = to,
    };
}

fn bottomOf(from: Pos) ?Step {
    if (from.y == height - 1) return null;
    const to = Pos {
        .x = from.x,
        .y = from.y + 1,
    };
    return if (!canBeTraversed(from, to)) null else .{
        .from = from,
        .to = to,
    };
}

const Pos = struct {
    x: usize,
    y: usize,
};

const Step = struct {
    from: Pos,
    to: Pos,
};
