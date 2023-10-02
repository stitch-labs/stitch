const std = @import("std");

pub fn write_to_file(file: std.fs.File, allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) !void {
    var bytes = try std.fmt.allocPrint(
        allocator,
        fmt,
        args,
    );
    const bytes_written = try file.write(bytes);
    _ = bytes_written;
    defer allocator.free(bytes);
}