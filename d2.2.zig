// solution for day 2, part 2

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

    while (file_reader.interface.takeDelimiterInclusive('\n')) |_line| {
        // remove line endings
        const line = std.mem.trimEnd(u8, _line, "\r\n");

        var product_id_ranges = std.mem.splitScalar(u8, line, ',');

        while (product_id_ranges.next()) |range_str| {
            var range_split = std.mem.splitScalar(u8, range_str, '-');
            const start_range = try std.fmt.parseInt(u64, range_split.next().?, 10);
            const end_range = try std.fmt.parseInt(u64, range_split.next().?, 10);

            next_num: for (start_range..end_range + 1) |num| {
                const num_as_string = try std.fmt.bufPrint(&string_num_buffer, "{d}", .{num});

                // Check if `str` is '1111', '22222', etc.
                if (allCharsSame(num_as_string)) {
                    invalid_ids_sum += num;
                    continue :next_num;
                }

                // if length is a prime number and we already know it's not "allCharsSame",
                // it is mathematically impossible to have other repeating patterns.
                // maximum u64 length is 20, so just check for, primes <= 20
                switch (num_as_string.len) {
                    2, 3, 5, 7, 11, 13, 17, 19 => continue :next_num,
                    else => {},
                }

                // if the string is too short, skip this whole check
                if (num_as_string.len < 4) continue :next_num;

                // normal check
                for (2..(num_as_string.len / 2) + 1) |pattern_len| {
                    if (num_as_string.len % pattern_len != 0) continue;

                    const pattern = num_as_string[0..pattern_len];
                    var match = true;
                    var i: usize = pattern_len;

                    while (i < num_as_string.len) : (i += pattern_len) {
                        if (!std.mem.eql(u8, pattern, num_as_string[i .. i + pattern_len])) {
                            match = false;
                            break;
                        }
                    }

                    if (match) {
                        invalid_ids_sum += num;
                        continue :next_num;
                    }
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

/// Check if `str` is '1111', '22222', etc.
fn allCharsSame(str: []u8) bool {
    if (str.len < 2) return false; // "1" cannot be repeated twice
    const first = str[0];
    for (str[1..]) |c| {
        if (c != first) return false;
    }
    return true;
}
