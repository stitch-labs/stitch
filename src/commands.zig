const std = @import("std");

const global = @import("global.zig");
const gen_abi_spec = @import("tools/gen_abi_spec.zig");
const gen_abi_encoding = @import("tools/gen_abi_encoding.zig");
const abi_grammar = @import("tools/abi/grammar.zig");

pub fn generate_abi_encoding(gpa: std.mem.Allocator, arena: std.mem.Allocator, args: []const []const u8) !void {
    if (args.len == 0) {
        gen_abi_encoding.print_usage();
        global.fatal("no command entered", .{});
    }

    if (args.len != 1) {
        gen_abi_encoding.print_usage();
        global.fatal("unknown command: {s}", .{args[0]});
    }

    const spec_path = args[0];
    const spec = try std.fs.cwd().readFileAlloc(arena, spec_path, std.math.maxInt(usize));

    // Required for json parsing.
    @setEvalBranchQuota(10000);

    var scanner = std.json.Scanner.initCompleteInput(arena, spec);
    var diagnostics = std.json.Diagnostics{};
    scanner.enableDiagnostics(&diagnostics);
    var parsed = std.json.parseFromTokenSource(abi_grammar.CoreRegistry, arena, &scanner, .{}) catch |err| {
        std.debug.print("line,col: {},{}\n", .{ diagnostics.getLine(), diagnostics.getColumn() });
        return err;
    };

    try gen_abi_encoding.render(gpa, parsed.value);
}

pub fn generate_abi_specification(gpa: std.mem.Allocator, arena: std.mem.Allocator, args: []const []const u8) !void {
    if (args.len == 0) {
        gen_abi_spec.print_usage();
        global.fatal("no command entered", .{});
    }

    if (args.len != 1) {
        gen_abi_spec.print_usage();
        global.fatal("unknown command: {s}", .{args[0]});
    }

    const spec_path = args[0];
    const spec = try std.fs.cwd().readFileAlloc(arena, spec_path, std.math.maxInt(usize));

    // Required for json parsing.
    @setEvalBranchQuota(10000);

    var scanner = std.json.Scanner.initCompleteInput(arena, spec);
    var diagnostics = std.json.Diagnostics{};
    scanner.enableDiagnostics(&diagnostics);
    var parsed = std.json.parseFromTokenSource(abi_grammar.CoreRegistry, arena, &scanner, .{}) catch |err| {
        std.debug.print("line,col: {},{}\n", .{ diagnostics.getLine(), diagnostics.getColumn() });
        return err;
    };

    try gen_abi_spec.render(gpa, parsed.value);
}
