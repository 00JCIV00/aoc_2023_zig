//! https://adventofcode.com/2023/day/4

const std = @import("std");
const ascii = std.ascii;
const fmt = std.fmt;
const heap = std.heap;
const log = std.log;
const mem = std.mem;
const meta = std.meta;

pub fn calcCards(alloc: mem.Allocator, lines: []const []const u8, idx: usize) !usize {
    var calc_sum: usize = 0;
    
    //for (lines[(idx + 1)..(idx + 1 + count)]) |line| {
    var card = mem.tokenizeAny(u8, lines[idx], ":|");
    _ = card.next();
    var win_iter = mem.tokenizeScalar(u8, card.next().?, ' ');
    var win_list = std.ArrayList(usize).init(alloc);
    while (win_iter.next()) |num| try win_list.append(try fmt.parseInt(usize, num, 10));
    const win_nums = try win_list.toOwnedSlice();
    defer alloc.free(win_nums);
    var hand_iter = mem.tokenizeScalar(u8, card.next().?, ' ');
    var hand_list = std.ArrayList(usize).init(alloc);
    while (hand_iter.next()) |num| try hand_list.append(try fmt.parseInt(usize, num, 10));
    const hand_nums = try hand_list.toOwnedSlice();
    defer alloc.free(hand_nums);

    var sum: usize = 0;
    for (win_nums) |w| {
        for (hand_nums) |h| {
            if (w != h) continue;
            sum += 1;
            calc_sum += try calcCards(alloc, lines, idx + sum);
        }
    }
    calc_sum += sum;
    //}

    return calc_sum;
}

pub fn main() !void {
    var alloc_buf: [1024 << 10]u8 = undefined;
    var fba = heap.FixedBufferAllocator.init(alloc_buf[0..]);
    const alloc = fba.allocator();

    const stdout_raw = std.io.getStdOut().writer();
    var stdout_buf = std.io.bufferedWriter(stdout_raw);
    const stdout = stdout_buf.writer();

    const file = @embedFile("star.txt");
    //const file = @embedFile("demo01.txt");
    var lines_iter = mem.tokenizeScalar(u8, file, '\n');
    var lines_list = std.ArrayList([]const u8).init(alloc);
    while (lines_iter.next()) |line| try lines_list.append(line);
    const lines = try lines_list.toOwnedSlice();
    defer alloc.free(lines);

    var total_1: usize = 0;
    var total_2: usize = 0;

    for (lines, 0..) |line, idx| {
        var card = mem.tokenizeAny(u8, line, ":|");
        _ = card.next();
        var win_iter = mem.tokenizeScalar(u8, card.next().?, ' ');
        var win_list = std.ArrayList(usize).init(alloc);
        while (win_iter.next()) |num| try win_list.append(try fmt.parseInt(usize, num, 10));
        const win_nums = try win_list.toOwnedSlice();
        defer alloc.free(win_nums);
        var hand_iter = mem.tokenizeScalar(u8, card.next().?, ' ');
        var hand_list = std.ArrayList(usize).init(alloc);
        while (hand_iter.next()) |num| try hand_list.append(try fmt.parseInt(usize, num, 10));
        const hand_nums = try hand_list.toOwnedSlice();
        defer alloc.free(hand_nums);
        
        var sum: usize = 0;
        for (win_nums) |w| {
            for (hand_nums) |h| {
                if (w != h) continue;
                sum = if (sum == 0) 1 else sum << 1;
            }
        }
        total_1 += sum;
        total_2 += try calcCards(alloc, lines, idx) + 1;
    }

    try stdout.print(
        \\Totals: 
        \\- Star 1: {d}
        \\- Star 2: {d}
        \\
        , .{ 
            total_1, 
            total_2, 
        }
    );
    try stdout_buf.flush();
}
