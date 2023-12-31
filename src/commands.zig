const std = @import("std");

const global = @import("global.zig");
const gen_abi_spec = @import("tools/gen_abi_spec.zig");
const gen_abi_bytecode = @import("tools/gen_abi_bytecode.zig");
const dump_sol_tokens = @import("tools/dump_sol_tokens.zig");
const ag = @import("interpreter/abi/grammar.zig");

pub fn generate_abi_bytecode(gpa: std.mem.Allocator, arena: std.mem.Allocator, args: []const []const u8) !void {
    if (args.len == 0) {
        gen_abi_bytecode.print_usage();
        global.fatal("no command entered", .{});
    }

    if (args.len != 1) {
        gen_abi_bytecode.print_usage();
        global.fatal("unknown command: {s}", .{args[0]});
    }

    const spec_path = args[0];
    const spec = try std.fs.cwd().readFileAlloc(arena, spec_path, std.math.maxInt(usize));

    // Required for json parsing.
    @setEvalBranchQuota(10000);

    var scanner = std.json.Scanner.initCompleteInput(arena, spec);
    var diagnostics = std.json.Diagnostics{};
    scanner.enableDiagnostics(&diagnostics);
    var parsed = std.json.parseFromTokenSource(ag.CoreRegistry, arena, &scanner, .{}) catch |err| {
        std.debug.print("line,col: {},{}\n", .{ diagnostics.getLine(), diagnostics.getColumn() });
        return err;
    };

    try gen_abi_bytecode.render(gpa, parsed.value);
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
    var parsed = std.json.parseFromTokenSource(ag.CoreRegistry, arena, &scanner, .{}) catch |err| {
        std.debug.print("line,col: {},{}\n", .{ diagnostics.getLine(), diagnostics.getColumn() });
        return err;
    };

    try gen_abi_spec.render(gpa, parsed.value);
}

pub fn dump_solidity_tokens(gpa: std.mem.Allocator, arena: std.mem.Allocator, args: []const []const u8) !void {
    _ = arena;
    if (args.len == 0) {
        dump_sol_tokens.print_usage();
        global.fatal("no command entered", .{});
    }

    if (args.len != 1) {
        dump_sol_tokens.print_usage();
        global.fatal("unknown command: {s}", .{args[0]});
    }

    const path = args[0];

    try dump_sol_tokens.render(gpa, path);
}
