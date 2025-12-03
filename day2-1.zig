// solution for day 2, part 1

const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("d2.txt", .{ .mode = .read_only });
    defer file.close();

    var threaded_io: std.Io.Threaded = .init_single_threaded;
    defer threaded_io.deinit();

    var file_buffer: [1024]u8 = undefined;
    var file_reader = file.reader(threaded_io.io(), &file_buffer);
    var string_num_buffer: [64]u8 = undefined;
    var invalid_ids_sum: u64 = 0;

    while (file_reader.interface.takeDelimiterExclusive('\n')) |line| {
        file_reader.interface.toss(1); // remove "\n"

        var product_id_ranges = std.mem.splitScalar(u8, line, ',');

        while (product_id_ranges.next()) |range| {
            var range_split_iter = std.mem.splitScalar(u8, range, '-');
            const start_range = try std.fmt.parseInt(u64, range_split_iter.next() orelse continue, 10);
            const end_range = try std.fmt.parseInt(u64, range_split_iter.next() orelse continue, 10);

            for (start_range..end_range + 1) |num| {
                const num_as_string = try std.fmt.bufPrint(&string_num_buffer, "{d}", .{num});
                if (num_as_string.len % 2 != 0) continue;

                const middle_of_string = num_as_string.len / 2;
                const first_half_of_string = num_as_string[0..middle_of_string];
                const second_half_of_string = num_as_string[middle_of_string..num_as_string.len];

                if (std.mem.eql(u8, first_half_of_string, second_half_of_string)) {
                    invalid_ids_sum += num;
                }
            }
        }
    } else |err| {
        switch (err) {
            error.EndOfStream => {},
            else => |e| return e,
        }
    }

    std.debug.print("sum: {}\n", .{invalid_ids_sum});
}
