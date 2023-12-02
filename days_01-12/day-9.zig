const std = @import("std");
const input = @embedFile("real-input/day-9.txt");

var alloc: std.mem.Allocator = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    alloc = gpa.allocator();

    var visited = std.AutoHashMap(Pos, void).init(alloc);
    defer visited.deinit();

    var knots = [_]Pos {.{.x = 0, .y = 0}} ** 10;

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        const dir = line[0];
        const count = try std.fmt.parseInt(i32, line[2..], 10);

        try print("{c} {d}\n", .{dir, count});
        
        var i: usize = 0;
        while (i < count):(i += 1) {
            switch (dir) {
                'R' => knots[0].x += 1,
                'L' => knots[0].x -= 1,
                'U' => knots[0].y += 1,
                'D' => knots[0].y -= 1,
                else => unreachable
            }

            var knot_index: usize = 1;
            while (knot_index < knots.len):(knot_index += 1) {
                const x_diff = knots[knot_index-1].x - knots[knot_index].x;
                const y_diff = knots[knot_index-1].y - knots[knot_index].y;

                const is_neighbor = (abs(x_diff) <= 1 and abs(y_diff) <= 1);

                if (!is_neighbor) {
                    knots[knot_index].x += sign(x_diff);
                    knots[knot_index].y += sign(y_diff);
                }
            }

            try visited.put(knots[knots.len-1], undefined);

            for (knots) |knot| try printPos(knot);
            try print("\n", .{});
        }
    }

    try print("visited positions = {d}\n", .{visited.count()});
}

fn printPos(pos: Pos) !void {
    try print("({d},{d}) ", .{pos.x, pos.y});
}

fn print(comptime format: []const u8, args: anytype) !void {
    try std.io.getStdOut().writer().print(format, args);
}

fn abs(value: i32) i32 {
    return if (value >= 0) value else -value;
}

fn sign(value: i32) i32 {
    if (value > 0) return 1;
    if (value < 0) return -1;
    return 0;
}

const Pos = struct {
    x: i32,
    y: i32,
};
