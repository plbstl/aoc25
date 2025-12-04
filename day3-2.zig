// solution for day 3, part 2

const std = @import("std");

pub fn main() !void {
    var threaded_io: std.Io.Threaded = .init_single_threaded;
    defer threaded_io.deinit();

    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const file = try std.fs.cwd().openFile("d3.txt", .{ .mode = .read_only });
    defer file.close();

    var file_buffer: [1024]u8 = undefined;
    var file_reader = file.reader(threaded_io.io(), &file_buffer);

    var joltages: std.ArrayList(u64) = .empty;
    defer joltages.deinit(allocator);

    const joltage_len = 12;

    while (file_reader.interface.takeDelimiterInclusive('\n')) |_line| {
        const line = std.mem.trimEnd(u8, _line, "\r\n");

        var num_digits_to_remove: usize = 0;
        if (line.len > joltage_len) {
            num_digits_to_remove = line.len - joltage_len;
        }

        var result_list: std.ArrayList(u8) = .empty;
        defer result_list.deinit(allocator);

        for (line) |current_digit| {
            while (num_digits_to_remove > 0 and result_list.items.len > 0 and result_list.getLast() < current_digit) {
                _ = result_list.pop();
                num_digits_to_remove -= 1;
            }
            try result_list.append(allocator, current_digit);
        }

        while (num_digits_to_remove > 0) {
            _ = result_list.pop();
            num_digits_to_remove -= 1;
        }

        const line_joltage = try std.fmt.parseInt(u64, result_list.items, 10);
        try joltages.append(allocator, line_joltage);
    } else |err| {
        switch (err) {
            error.EndOfStream => {},
            else => |e| return e,
        }
    }

    var total: u128 = 0;
    for (joltages.items) |j| {
        total += j;
    }

    std.debug.print("result: {}\n", .{total});
}
