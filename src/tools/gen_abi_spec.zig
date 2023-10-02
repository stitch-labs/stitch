const std = @import("std");
const ag = @import("abi/grammar.zig");
const Allocator = std.mem.Allocator;

const ExtendedStructSet = std.StringHashMap(void);

const auto_generated_tag =
    \\//This file is auto-generated by tools/gen_abi_spec.zig
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

const bindings = auto_generated_tag ++
    \\
    \\const Version = @import("std").SemanticVersion;
    \\pub const AbiFunctionType = enum(u8) {
    \\    function = 0x0,
    \\};
    \\pub const AbiComponentType = enum(u8) {
    \\    tuple = 0x10,
    \\    uint256 = 0x11,
    \\};
    \\const AbiFunction = struct {
    \\    name: []const u8,
    \\    type: AbiFunctionType,
    \\    inputs: []AbiComponent,
    \\    outputs: []AbiComponent,
    \\};
    \\const AbiComponent = struct {
    \\    name: []const u8,
    \\    type: AbiComponentType,
    \\    components: []AbiComponent,
    \\};
    \\
    \\
;

pub fn render(writer: anytype, allocator: Allocator, registry: ag.CoreRegistry) !void {
    _ = writer;
    _ = registry;
    _ = allocator;

    const file = try std.fs.cwd().createFile(
        "src/codegen/abi/bindings.zig",
        .{ .read = true },
    );
    defer file.close();

    const bytes_written = try file.writeAll(bindings);
    _ = bytes_written;
}

pub fn print_usage() void {
    std.log.info("{s}", .{usage});
}
