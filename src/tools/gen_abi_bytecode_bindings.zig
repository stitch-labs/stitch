const std = @import("std");

const ag = @import("abi/grammar.zig");
const bytes = @import("../bytes.zig");

const usage =
    \\Usage: stitch bytecode-bindings-abi <abi .json>
    \\
    \\Generates EVM bytecode bindings for an ABI specification .json (either core or
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
    try render_abi_bytecode_bindings(file, allocator, registry.contract_abi);
}

fn render_abi_bytecode_bindings(file: std.fs.File, allocator: std.mem.Allocator, functions: []ag.AbiFunction) !void {
    for (functions) |function| {
        _ = switch (function.type) {
            ag.AbiFunctionType.function => {
                if (function.inputs.len != 0) {
                    try bytes.write_to_file(file, allocator, "{s}", .{function.name});
                    try render_function_inputs(file, allocator, function.inputs);
                    try bytes.write_to_file(file, allocator, "\n", .{});
                }
            },
        };
    }
}

fn render_function_inputs(file: std.fs.File, allocator: std.mem.Allocator, inputs: []ag.AbiComponent) !void {
    if (inputs.len != 0) {
        try bytes.write_to_file(file, allocator, "(", .{});
        for (0.., inputs) |i, input| {
            _ = switch (input.type) {
                ag.AbiComponentType.tuple, ag.AbiComponentType.tuple_arr, ag.AbiComponentType.uint256_arr => {
                    try render_components(file, allocator, input.components);
                    if (i != inputs.len - 1) {
                        try render_component(file, allocator, ",");
                    }
                },

                ag.AbiComponentType.uint256 => {
                    try render_component(file, allocator, "uint256");
                },
            };
        }
        try bytes.write_to_file(file, allocator, ")", .{});
    }
}

fn render_components(file: std.fs.File, allocator: std.mem.Allocator, components: []ag.AbiComponent) !void {
    if (components.len != 0) {
        try bytes.write_to_file(file, allocator, "(", .{});
        for (0.., components) |i, component| {
            _ = switch (component.type) {
                ag.AbiComponentType.uint256 => {
                    try render_component(file, allocator, "uint256");
                    if (i != components.len - 1) {
                        try render_component(file, allocator, ",");
                    }
                },

                ag.AbiComponentType.uint256_arr => {
                    try render_component(file, allocator, "uint256[]");
                    if (i != components.len - 1) {
                        try render_component(file, allocator, ",");
                    }
                },

                ag.AbiComponentType.tuple_arr => {
                    try render_components(file, allocator, component.components);
                    try render_component(file, allocator, "[]");
                },

                else => {},
            };
        }
        try bytes.write_to_file(file, allocator, ")", .{});
    }
}

fn render_component(file: std.fs.File, allocator: std.mem.Allocator, comptime data: []const u8) !void {
    try bytes.write_to_file(
        file,
        allocator,
        data,
        .{},
    );
}

pub fn print_usage() void {
    std.log.info("{s}", .{usage});
}
