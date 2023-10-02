const std = @import("std");

const ag = @import("abi/grammar.zig");
const bytes = @import("../bytes.zig");

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
    try render_abi_functions(file, allocator, registry.contract_abi);
}

fn render_abi_functions(file: std.fs.File, allocator: std.mem.Allocator, functions: []ag.AbiFunction) !void {
    for (functions) |function| {
        const t = switch (function.type) {
            ag.AbiFunctionType.function => {
                try bytes.write_to_file(
                    file,
                    allocator,
                    "{s}(",
                    .{function.name},
                );
                if (function.inputs.len != 0) {
                    try render_input_components(file, allocator, function.inputs);
                }
                try bytes.write_to_file(
                    file,
                    allocator,
                    ")\n",
                    .{},
                );
            },
        };
        _ = t;
    }
}

fn render_input_components(file: std.fs.File, allocator: std.mem.Allocator, inputs: []ag.AbiComponent) !void {
    for (inputs) |input| {
        if (input.components.len != 0) {
            const t = switch (input.type) {
                ag.AbiComponentType.tuple => {
                    try render_input_components_tuple(file, allocator, input.components);
                },

                else => {},
            };
            _ = t;
        }
    }
}

fn render_input_components_tuple(file: std.fs.File, allocator: std.mem.Allocator, components: []ag.AbiComponent) !void {
    for (components) |component| {
        const t = switch (component.type) {
            ag.AbiComponentType.uint256 => {
                try render_input_components_tuple_uint256(file, allocator);
            },

            else => {},
        };
        _ = t;
    }
}

fn render_input_components_tuple_uint256(file: std.fs.File, allocator: std.mem.Allocator) !void {
    try bytes.write_to_file(
        file,
        allocator,
        "uint256,",
        .{},
    );
}

pub fn print_usage() void {
    std.log.info("{s}", .{usage});
}
