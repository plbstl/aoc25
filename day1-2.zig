// solution for day 1, part 2

const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("d1.txt", .{ .mode = .read_only });
    defer file.close();

    var threaded_io: std.Io.Threaded = .init_single_threaded;
    defer threaded_io.deinit();

    var dial: i32 = 50;
    var password_hits: u32 = 0;

    var file_buffer: [64]u8 = undefined;
    var file_reader = file.reader(threaded_io.io(), &file_buffer);

    while (file_reader.interface.takeDelimiterInclusive('\n')) |line| {
        // remove line endings
        const trimmed = std.mem.trimEnd(u8, line, "\r\n");
        if (trimmed.len < 2) continue;

        const direction = trimmed[0]; // 'L' or 'R'
        std.debug.assert(direction == 'L' or direction == 'R');
        const raw_num_str = trimmed[1..];

        // parse distance
        const distance = try std.fmt.parseInt(u32, raw_num_str, 10);

        // full laps:
        // every 100 clicks guarantees passing 0 exactly once
        const laps = distance / 100;
        password_hits += laps;

        // remainder movement:
        // cast to i32 for easier math with the dial
        const remainder = @as(i32, @intCast(distance % 100));

        if (direction == 'R') {
            // check if the partial move crosses the overflow boundary (100)
            if (dial + remainder >= 100) {
                password_hits += 1;
            }
            // update dial position
            dial = @mod(dial + remainder, 100);
        } else {
            // 'L' logic
            // we only cross 0 going left if we are currently above 0,
            // and the subtraction takes us to 0 or below.
            // note: if we start at 0 and move Left, we go to 99 (no hit)
            if (dial != 0 and (dial - remainder <= 0)) {
                password_hits += 1;
            }
            // update dial position
            dial = @mod(dial - remainder, 100);
        }
    } else |err| {
        switch (err) {
            error.EndOfStream => {},
            else => |e| std.debug.print("\n\nERROR: {any}\n", .{e}),
        }
    }

    std.debug.print("password: {} \n", .{password_hits});
}
