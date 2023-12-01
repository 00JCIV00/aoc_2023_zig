const std = @import("std");
const ascii = std.ascii;
const fmt = std.fmt;
const mem = std.mem;
const meta = std.meta;

pub fn main() !void {
    const stdout_raw = std.io.getStdOut().writer();
    var stdout_buf = std.io.bufferedWriter(stdout_raw);
    const stdout = stdout_buf.writer();

    const do_star_1 = false;

    const file = try std.fs.cwd().openFile("star.txt", .{});
    var reader = file.reader();
    
    const NumMap = enum(u8){
        zero,
        one,
        two,
        three,
        four,
        five,
        six,
        seven,
        eight,
        nine,
    };
    const nums = "0123456789";

    var total: u16 = 0;
    const line_len = 100;
    var line_buf: [line_len]u8 = .{ 0 } ** line_len;
    try stdout.print("Values:\n", .{});

    while (try reader.readUntilDelimiterOrEof(line_buf[0..], '\n')) |line| {
        defer line_buf = .{ 0 } ** line_len;
        var parsed_line_buf: [line_len]u8 = .{ 0 } ** line_len;
        const parsed_line = if (do_star_1) line else parsedLine: {
            try stdout.print("- Line: {s}\n", .{ line });
            for (line, parsed_line_buf[0..line.len], 0..) |char, *p_char, idx| {
                switch (char) {
                    '0'...'9' => p_char.* = char,
                    else => {
                        inline for (meta.fields(NumMap)) |num| {
                            if (mem.indexOf(u8, line[idx..@min(line.len, idx + num.name.len)], num.name)) |_| p_char.* = nums[num.value];
                        }
                    }
                }
            }
            try stdout.print("- Parsed: {s}\n", .{ parsed_line_buf[0..] });
            break :parsedLine parsed_line_buf[0..];
        };
        var val_buf: [2]u8 = .{ 0, 0 };
        val_buf[0] = parsed_line[
            mem.indexOfAny(u8, parsed_line, nums) orelse {
                try stdout.print("- No #\n", .{});
                continue;
            }
        ];
        val_buf[1] = parsed_line[mem.lastIndexOfAny(u8, parsed_line, "0123456789").?];
        const value: u16 = try fmt.parseInt(u8, val_buf[0..], 0);
        try stdout.print("- {d}\n", .{ value });
        total += value;
    }

    try stdout.print("\nTotal: {d}\n", .{ total });
    try stdout_buf.flush();
}
