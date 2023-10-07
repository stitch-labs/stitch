const std = @import("std");
const util = @import("../util.zig");
const repl = @import("../interpreter/sol/repl.zig");

const auto_generated_tag =
    \\//This file is auto-generated by tools/dump_sol_tokens.zig
;

const usage =
    \\Usage: stitch dump-sol-tokens <solidity sol>
    \\
    \\Dump a file containing the parsed & interpreted tokens from an Solidity specification .sol
    \\
;

pub fn render(allocator: std.mem.Allocator, source_filepath: []const u8) !void {
    const filename = try get_filepath_name(source_filepath);
    const output_filepath = try std.fmt.allocPrint(
        allocator,
        "src/autogen/tokens/{s}",
        .{filename},
    );
    defer allocator.free(output_filepath);
    const file = try std.fs.cwd().createFile(
        output_filepath,
        .{ .read = true },
    );
    defer file.close();
    try repl.start(file, allocator, source_filepath);
}

fn get_filepath_name(path: []const u8) !([]const u8) {
    var i: usize = path.len;

    for (path[0 .. path.len - 1], 0..) |c, index| {
        if (c == '/') {
            i = index;
        }
    }

    if (i == path.len) {
        return path;
    }

    return path[i + 1 .. path.len - 4];
}

pub fn print_usage() void {
    std.log.info("{s}", .{usage});
}
