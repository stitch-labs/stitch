const std = @import("std");
const lexer = @import("lexer.zig");
const language = @import("language.zig");
const util = @import("../../util.zig");

const max_column_width = 15;

pub fn start(output_file: std.fs.File, allocator: std.mem.Allocator, filepath: []const u8) !void {
    const file_path = try getFilePath(filepath);

    const file = try std.fs.openFileAbsolute(file_path, .{});
    defer file.close();

    var file_contents = std.ArrayList(u8).init(allocator);
    defer file_contents.deinit();

    const read_chunk_size = 2000;
    var read_buffer = try allocator.alloc(u8, read_chunk_size);

    var line_index: usize = 0;

    while (true) {
        const bytes_read = try file.read(read_buffer);
        if (bytes_read == 0) break;

        try file_contents.appendSlice(read_buffer[0..bytes_read]);

        var line_iterator = std.mem.split(u8, read_buffer[0..bytes_read], "\n");

        while (line_iterator.next()) |line| {
            line_index += 1;

            if (line.len == 0) continue; // skip empty lines
            var lex = lexer.Lexer(){
                .input = line,
                .position = 0,
                .read_position = 0,
                .ch = line[0],
            };

            var token_index: usize = 0;

            try util.write_to_file(
                output_file,
                allocator,
                "[{d}] → {s}\n",
                .{ line_index, line },
            );
            // std.debug.print("[{d}] → {s}\n", .{ line_index, line });

            while (true) {
                var token = lex.next_token();
                if (token.type == language.Type.eof) break;

                const token_type = language.str(token.type);
                const token_literal = token.literal;

                const padding_count = util.max(0, max_column_width - token_type.len);
                const padding = try util.padding_runtime(allocator, padding_count);
                defer allocator.free(padding);

                try util.write_to_file(
                    output_file,
                    allocator,
                    "   |-[{d}] ← {s}::{s}\n",
                    .{ token_index, token_type, token_literal },
                );
                // std.debug.print("   |-[{d}] ← {s}::{s}\n", .{ token_index, token_type, token_literal });

                token_index += 1;
            }
        }
    }

    allocator.free(read_buffer);
    std.debug.print("Output saved to: {s}", .{"src/autogen/tokens/<Contract>.sol"});
}

fn getFilePath(filepath: []const u8) ![]const u8 {
    var path_buffer: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    return std.fs.realpath(filepath, &path_buffer);
}
