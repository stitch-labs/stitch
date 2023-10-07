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

pub fn padding(comptime count: usize) []const u8 {
    comptime var spaces = [_]u8{0} ** count;

    comptime {
        var i: usize = 0;
        while (i < count) : (i += 1) {
            spaces[i] = ' ';
        }
    }

    return &spaces;
}

pub fn padding_runtime(allocator: std.mem.Allocator, count: usize) ![]u8 {
    var spaces = try allocator.alloc(u8, count);
    errdefer allocator.free(spaces);

    for (spaces) |*b| {
        b.* = ' ';
    }

    return spaces;
}

pub fn max(a: usize, b: usize) usize {
    return if (a > b) a else b;
}
