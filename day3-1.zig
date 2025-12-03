// solution for day 3, part 1

const std = @import("std");

pub fn main() !void {
    var threaded_io: std.Io.Threaded = .init_single_threaded;
    defer threaded_io.deinit();

    const sa = std.heap.smp_allocator;

    const file = try std.fs.cwd().openFile("d3.txt", .{ .mode = .read_only });
    defer file.close();

    var file_buffer: [1024]u8 = undefined;
    var file_reader = file.reader(threaded_io.io(), &file_buffer);

    var joltages: std.ArrayList(u7) = .empty;
    defer joltages.deinit(sa);

    while (file_reader.interface.takeDelimiterInclusive('\n')) |_line| {
        // remove line endings
        const line = std.mem.trimEnd(u8, _line, "\r\n");

        // check for tens digit
        var tens_digit: u8 = 0;
        var tens_digit_index: usize = 0;
        for (line[0 .. line.len - 1], 0..) |char, i| {
            if (char > tens_digit) {
                tens_digit = char;
                tens_digit_index = i;
            }
        }

        // check for units digit
        var units_digit: u8 = 0;
        var units_digit_index: usize = 0;
        for (line[tens_digit_index + 1 ..], tens_digit_index + 1..) |char, i| {
            if (char > units_digit) {
                units_digit = char;
                units_digit_index = i;
            }
        }

        const joltage_str: []const u8 = &[_]u8{ tens_digit, units_digit };
        const joltage = try std.fmt.parseInt(u7, joltage_str, 10);
        try joltages.append(sa, joltage);
    } else |err| {
        switch (err) {
            error.EndOfStream => {},
            else => |e| return e,
        }
    }

    var total: u64 = 0;
    for (joltages.items) |value| {
        total += value;
    }

    std.debug.print("result: {}\n", .{total});
}
