//! https://adventofcode.com/2023/day/4

const std = @import("std");
const ascii = std.ascii;
const fmt = std.fmt;
const heap = std.heap;
const log = std.log;
const mem = std.mem;
const meta = std.meta;


pub fn main() !void {
    var alloc_buf: [1024 << 10]u8 = undefined;
    var fba = heap.FixedBufferAllocator.init(alloc_buf[0..]);
    const alloc = fba.allocator();

    const stdout_raw = std.io.getStdOut().writer();
    var stdout_buf = std.io.bufferedWriter(stdout_raw);
    const stdout = stdout_buf.writer();

    const file = @embedFile("star.txt");
    var lines_iter = mem.tokenizeScalar(u8, file, '\n');
    var lines_list = std.ArrayList([]const u8).init(alloc);
    while (lines_iter.next()) |line| try lines_list.append(line);
    const lines = try lines_list.toOwnedSlice();
    defer alloc.free(lines);

    var total_1: usize = 0;
    var total_2: usize = 0;

    for (lines, 0..) |line, idx| {
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
