const std = @import("std");
const ag = @import("abi/grammar.zig");
const Allocator = std.mem.Allocator;
const print = std.debug.print;

const ExtendedStructSet = std.StringHashMap(void);

const auto_generated_tag =
    \\This file is auto-generated by tools/gen_abi_spec.zig
;

const usage =
    \\Usage: stitch spec-abi <abi json>
    \\
    \\Generates Zig bindings for an ABI specification .json (either core or
    \\extinst versions). The result, printed to stdout, should be used to update
    \\files in src/codegen/abi. Don't forget to format the output.
    \\
    \\The relevant specifications can be obtained from the Stitch Registry
    \\https://github.com/registry.stitch.com/
    \\
;

pub fn render(writer: anytype, allocator: Allocator, registry: ag.CoreRegistry) !void {
    _ = writer;
    _ = registry;
    _ = allocator;

    // std.log.info("{s}", .{auto_generated_tag});

    // try writer.writeAll(
    //     \\//! This file is auto-generated by stitch/tools/gen_abi_spec.zig
    //     \\
    //     \\
    // );

    // try writer.print(
    //     \\pragma solidity ^{}.{}.{}
    //     \\
    //     \\contract {s} {{
    //     \\
    // ,
    //     .{ registry.major_version, registry.minor_version, registry.revision, registry.magic_number },
    // );

    // for (0.., registry.contract_abi) |i, function| {
    //     _ = i;

    //     if (function.type == ag.AbiFunctionType.function) {
    //         var input_list_len: usize = function.inputs.len;
    //         var output_list_len: usize = function.outputs.len;

    //         try writer.print(
    //             \\      function {s}()
    //         ,
    //             .{function.name},
    //         );

    //         if (input_list_len == 0) {
    //             if (input_list_len == output_list_len) {
    //                 try writer.print(
    //                     \\ public pure
    //                 ,
    //                     .{},
    //                 );
    //             }
    //         }

    //         try writer.print(
    //             \\ {{}}
    //         ,
    //             .{},
    //         );
    //     }

    //     // if (function.type == sag.AbiFunctionType[@intFromEnum(sag.AbiFunctionType.function)]) {
    //     //     try writer.print(
    //     //         \\
    //     //         \\ struct {{
    //     //         \\
    //     //     ,
    //     //         .{},
    //     //     );

    //     //     for (0.., function.inputs) |j, input| {
    //     //         _ = j;

    //     //         try writer.print(
    //     //             \\    {} {s};
    //     //         ,
    //     //             .{ input.type, input.name },
    //     //         );
    //     //     }

    //     //     try writer.print(
    //     //         \\ }}
    //     //         \\
    //     //     , .{});
    //     // }
    // }

    // try writer.print(
    //     \\
    //     \\}}
    //     \\
    //     \\
    // ,
    //     .{},
    // );

}

pub fn print_usage() void {
    std.log.info("{s}", .{usage});
}
