const std = @import("std");
const input = @embedFile("test-input/day-2.txt");

pub fn main() !void {
    var total_score: u32 = 0;

    var round_it = std.mem.tokenize(u8, input, "\n");
    while (round_it.next()) |round| {
        for (games) |game| {
            if (std.mem.eql(u8, game.string, round)) {
                std.debug.print("{s} -> {d}\n", .{round, game.score});
                total_score += game.score;
            }
        }
    }

    std.debug.print("total score = {d}\n", .{total_score});
}

const games = [_]Game {
    .{ .string = "A X", .score = 1 + 3 },
    .{ .string = "A Y", .score = 2 + 6 },
    .{ .string = "A Z", .score = 3 + 0 },
    .{ .string = "B X", .score = 1 + 0 },
    .{ .string = "B Y", .score = 2 + 3 },
    .{ .string = "B Z", .score = 2 + 6 },
    .{ .string = "C X", .score = 3 + 6 },
    .{ .string = "C Y", .score = 3 + 0 },
    .{ .string = "C Z", .score = 3 + 3 },
};

const Game = struct {
    string: []const u8,
    score: u32,
};
