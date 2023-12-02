const std = @import("std");
const ascii = std.ascii;
const fmt = std.fmt;
const heap = std.heap;
const mem = std.mem;
const meta = std.meta;

pub const Game = struct{
    red: u8 = 0,
    green: u8 = 0,
    blue: u8 = 0,

    pub fn fromLn(raw_line: []const u8) !@This() {
        var game = @This(){};
        const line = raw_line[((mem.indexOf(u8, raw_line, ": ") orelse return error.InvalidLine) + 1)..];
        var pulls = mem.tokenizeScalar(u8, line, ';');
        while (pulls.next()) |pull| {
            var die = mem.tokenizeScalar(u8, pull, ',');
            while (die.next()) |dice| {
                var dice_iter = mem.tokenizeScalar(u8, dice, ' ');
                const num: u8 = try fmt.parseInt(u8, dice_iter.next() orelse return error.InvalidLine, 0);
                const color = dice_iter.next() orelse return error.InvalidLine;
                inline for (meta.fields(@This())) |field| { 
                    if (mem.eql(u8, field.name, color)) @field(game, field.name) = @max(@field(game, field.name), num);
                }
            }
        }
        return game;
    }
};

pub fn main() !void {
    var alloc_buf: [1024 << 10]u8 = undefined;
    var fba = heap.FixedBufferAllocator.init(alloc_buf[0..]);
    const alloc = fba.allocator();

    const stdout_raw = std.io.getStdOut().writer();
    var stdout_buf = std.io.bufferedWriter(stdout_raw);
    const stdout = stdout_buf.writer();

    const file = @embedFile("star.txt");
    var lines = mem.tokenizeScalar(u8, file, '\n');

    var games = std.ArrayList(Game).init(alloc);
    while (lines.next()) |line| try games.append(try Game.fromLn(line));

    try stdout.print("Valid Games:\n", .{});
    var total_1: u16 = 0;
    var total_2: u64 = 0;
    for (try games.toOwnedSlice(), 0..) |game, idx| {
        // Star 2
        var power: u32 = 1;
        inline for (meta.fields(Game)) |field| power *= @field(game, field.name);
        total_2 += power;
        // Star 1
        if (
            game.red > 12 or
            game.green > 13 or
            game.blue > 14
        ) continue;
        total_1 += @as(u16, @intCast(idx)) + 1;
        try stdout.print("- Game: {d} {any}\n", .{ idx + 1, game });
    }

    try stdout.print(
        \\Totals: 
        \\- Star 1: {d}
        \\- Star 2: {d}
        \\
        , .{ 
            total_1, 
            total_2 
        }
    );
    try stdout_buf.flush();
}
