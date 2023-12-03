const std = @import("std");
const ascii = std.ascii;
const fmt = std.fmt;
const heap = std.heap;
const log = std.log;
const mem = std.mem;
const meta = std.meta;

pub const PartNum = struct{
    x_start: usize,
    x_end: usize,
    value: usize,
};

pub fn neighborSum(alloc: mem.Allocator, sym_x: usize, lines: []const []const u8) ![2]usize {
    var sum: usize = 0;
    var part_num_list = std.ArrayList(PartNum).init(alloc);
    
    for (lines) |line| {
        var idx: usize = 0;
        while (idx < line.len) {
            if (!ascii.isDigit(line[idx])) {
                idx += 1;
                continue;
            }
            const end = (mem.indexOfNone(u8, line[idx..], "0123456789") orelse (line[idx..].len)) + idx;
            try part_num_list.append(.{
                .x_start = idx -| 1,
                .x_end = @min(end +| 1, line.len),
                .value = try fmt.parseInt(usize, line[idx..end], 10),
            });
            idx = end;
        }
    }
    const part_nums = try part_num_list.toOwnedSlice();
    defer alloc.free(part_nums);
    var ratio: usize = 1;
    var ratio_count: usize = 0;
    for (part_nums) |part_num| {
        log.debug("- {any}", .{ part_num });
        for (part_num.x_start..part_num.x_end) |x| {
            if (sym_x != x) continue;
            //log.debug("- Added: {d}", .{ part_num.value });
            sum += part_num.value;
            ratio *= if (lines[1][sym_x] == '*') part_num.value else 0;
            ratio_count += 1;
            break;
        }
    }
    if (ratio_count != 2) ratio = 0;

    log.debug("Ratio: {d}", .{ ratio });

    return .{ sum, ratio };
}

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
    _ = &total_2;

    for (lines, 0..) |line, y| {
        for (line, 0..) |char, x| {
            if (mem.indexOfScalar(u8, "0123456789.", char)) |_| continue;
            log.debug("Symbol: {d}, {d}", .{ x, y });
            const sum_ratio = try neighborSum(alloc, x, &.{ lines[y - 1], line, lines[y + 1] });
            total_1 += sum_ratio[0];
            total_2 += sum_ratio[1];
        }
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
