// solution for day 1, part 1

const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("d1.txt", .{ .mode = .read_only });
    defer file.close();

    var threaded_io: std.Io.Threaded = .init_single_threaded;
    defer threaded_io.deinit();

    var dial: i16 = 50;
    var password: u32 = 0;

    var file_buffer: [16]u8 = undefined;
    var file_reader = file.reader(threaded_io.io(), &file_buffer);

    while (file_reader.interface.takeDelimiter('\n')) |line| {
        if (line) |ln| {
            var ln_copy = ln[0..];
            std.debug.assert(ln_copy[0] == 'L' or ln_copy[0] == 'R');
            ln_copy[0] = if (ln[0] == 'L') '-' else '+';

            const distance = try std.fmt.parseInt(i16, ln_copy, 10);
            dial = @mod(dial + distance, 100);

            if (@mod(dial, 100) == 0) password += 1;
        } else break;
    } else |err| {
        std.debug.print("\n\nERROR: {any}\n", .{err});
    }

    std.debug.print("password: {} \n", .{password});
}
