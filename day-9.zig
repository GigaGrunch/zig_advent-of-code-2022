const std = @import("std");
const input = @embedFile("test-input/day-9.txt");

var alloc: std.mem.Allocator = undefined;
var h_pos: Pos = undefined;
var t_pos: Pos = undefined;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    alloc = gpa.allocator();

    h_pos = .{ .x = 0, .y = 0 };
    t_pos = .{ .x = 0, .y = 0 };

    var lines_it = std.mem.tokenize(u8, input, "\r\n");
    while (lines_it.next()) |line| {
        const dir = line[0];
        const count = line[2] - '0';
        
        var i: usize = 0;
        while (i < count):(i += 1) {
            switch (dir) {
                'R' => h_pos.x += 1,
                'L' => h_pos.x -= 1,
                'U' => h_pos.y += 1,
                'D' => h_pos.y -= 1,
                else => unreachable
            }

            const x_diff = h_pos.x - t_pos.x;
            const y_diff = h_pos.y - t_pos.y;

            if (abs(x_diff) > 1 or (x_diff != 0 and y_diff != 0)) {
                t_pos.x += sign(x_diff);
            }
            if (abs(y_diff) > 1 or (y_diff != 0 and y_diff != 0)) {
                t_pos.y += sign(y_diff);
            }

            std.debug.print("H is at ({d},{d}), T is at ({d},{d})\n", .{h_pos.x, h_pos.y, t_pos.x, t_pos.y});
        }
    }
}

fn abs(value: i32) i32 {
    return if (value >= 0) value else -value;
}

fn sign(value: i32) i32 {
    return if (value >= 0) 1 else -1;
}

const Pos = struct {
    x: i32,
    y: i32,
};
