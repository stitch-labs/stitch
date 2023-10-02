const std = @import("std");

const ag = @import("abi/grammar.zig");
const bytes = @import("../bytes.zig");

const auto_generated_tag =
    \\//This file is auto-generated by tools/gen_abi_encoding.zig
;

const usage =
    \\Usage: stitch encode-abi <abi .json>
    \\
    \\Generates EVM bytecode for an ABI specification .json (either core or
    \\extinst versions). The result, printed to stdout, should be used to update
    \\files in src/codegen/bytecode. Don't forget to format the output.
    \\
    \\The relevant specifications can be obtained from the Stitch Registry
    \\https://github.com/registry.stitch.com/
    \\
;

pub fn render(allocator: std.mem.Allocator, registry: ag.CoreRegistry) !void {
    const file = try std.fs.cwd().createFile(
        "src/codegen/abi/bytecode",
        .{ .read = true },
    );
    defer file.close();

    try bytes.write_to_file(
        file,
        allocator,
        "{s}\n",
        .{auto_generated_tag},
    );

    for (0.., registry.contract_abi) |i, function| {
        _ = i;

        if (function.type == ag.AbiFunctionType.function) {
            var input_list_len: usize = function.inputs.len;
            _ = input_list_len;
            var output_list_len: usize = function.outputs.len;
            _ = output_list_len;

            try bytes.write_to_file(
                file,
                allocator,
                "{s}()\n",
                .{function.name},
            );
        }
    }
}

pub fn print_usage() void {
    std.log.info("{s}", .{usage});
}
