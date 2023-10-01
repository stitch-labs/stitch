const std = @import("std");
const builtin = @import("builtin");
const assert = std.debug.assert;
const io = std.io;
const fs = std.fs;
const mem = std.mem;
const process = std.process;
const Allocator = mem.Allocator;
const ArrayList = std.ArrayList;
const Ast = std.zig.Ast;
const warn = std.log.warn;
const ThreadPool = std.Thread.Pool;
const cleanExit = std.process.cleanExit;

const global = @import("global.zig");
const commands = @import("commands.zig");
const tracy = @import("tracy.zig");
const gen_abi_spec = @import("tools/gen_abi_spec.zig");
const grammar = @import("tools/abi/grammar.zig");

pub const debug_extensions_enabled = builtin.mode == .Debug;

var log_scopes: std.ArrayListUnmanaged([]const u8) = .{};
var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};

pub const StdOptions = struct {
    pub const log_level: std.log.Level = switch (builtin.mode) {
        .Debug => .debug,
        .ReleaseSafe, .ReleaseFast => .info,
        .ReleaseSmall => .err,
    };
};

pub const StdColor = enum {
    auto,
    off,
    on,
};

const about =
    \\
    \\Incredibly fast EVM runtime, bundler, test runner,
    \\and package manager – all in one
    \\
    \\🚀 What is Stitch?
    \\
    \\🔵 Stitch is under active development. Use it to speed up
    \\   your development workflows or run simpler production
    \\   code in resource-constrained environments like localhost.
    \\   We're working on more complete runtime compatibility and 
    \\   integration with existing frameworks like foundry and hardhat.
    \\   Join the [Discord](https://stitch-labs.sh/discord) and watch
    \\   the [GitHub repository](https://github.com/stitch-labs/stitch)
    \\   to keep tabs on future releases.
    \\
    \\🧵 Stitch is an all-in-one toolkit for EVM Development.
    \\   It ships as a single executable called `stitch`.
    \\
    \\   At its core is the _Stitch runtime_, a fast EVM client
    \\   designed as an EVM runtime written in Zig and powered by 
    \\   StitchScriptCore under the hood,
    \\   dramatically reducing startup times and memory usage.
    \\
    \\📦 The `stitch` command-line tool also implements a test runner,
    \\   script runner, and a light ethereum client. a novel package
    \\   manager. Instead of 100 dev tools for development, you only
    \\   need `stitch`. Stitch's built-in tools are significantly
    \\   faster than existing options and usable in existing ethereum
    \\   projects with little to no changes.
    \\
;

const normal_usage = about ++
    \\
    \\Usage: stitch [command] [options]
    \\
    \\Commands:
    \\ 
    \\  spec-abi         Generates Zig bindings for an ABI specification .json
    \\  spec-sol         Generates Zig bindings for an Solidity specification .sol
    \\
    \\General Options:
    \\
    \\  -h, --help       Print command-specific usage
    \\
;

const debug_usage = normal_usage ++
    \\
    \\Debug Commands:
    \\
    \\  dump             Dump a file containing cached Zig bindings
    \\
;

const usage = if (debug_extensions_enabled) debug_usage else normal_usage;

pub fn main() anyerror!void {
    const use_gpa = builtin.os.tag != .wasi;
    const gpa = gpa: {
        if (use_gpa) {
            break :gpa general_purpose_allocator.allocator();
        }
        break :gpa std.heap.page_allocator;
    };
    defer if (use_gpa) {
        _ = general_purpose_allocator.deinit();
    };
    var arena_instance = std.heap.ArenaAllocator.init(gpa);
    defer arena_instance.deinit();
    const arena = arena_instance.allocator();

    const args = try process.argsAlloc(arena);

    return mainArgs(gpa, arena, args);
}

pub fn log(
    comptime level: std.log.Level,
    comptime scope: @TypeOf(.EnumLiteral),
    comptime format: []const u8,
    args: anytype,
) void {
    // Hide debug messages unless:
    // * logging enabled with `-Dlog`.
    // * the --debug-log arg for the scope has been provided
    if (@intFromEnum(level) > @intFromEnum(std.options.log_level) or
        @intFromEnum(level) > @intFromEnum(std.log.Level.info))
    {
        const scope_name = @tagName(scope);
        for (log_scopes.items) |log_scope| {
            if (mem.eql(u8, log_scope, scope_name))
                break;
        } else return;
    }

    const prefix1 = comptime level.asText();
    const prefix2 = if (scope == .default) ": " else "(" ++ @tagName(scope) ++ "): ";

    // Print the message to stderr, silently ignoring any errors
    std.debug.print(prefix1 ++ prefix2 ++ format ++ "\n", args);
}

pub fn mainArgs(gpa: Allocator, arena: Allocator, args: []const []const u8) !void {
    if (args.len <= 1) {
        print_usage(args[0]);
        global.fatal("expected command argument", .{});
    }

    defer log_scopes.deinit(gpa);

    const cmd = args[1];
    const cmd_args = args[2..];

    if (mem.eql(u8, cmd, "build")) {
        return build(gpa, arena, cmd_args);
    } else if (mem.eql(u8, cmd, "spec-abi")) {
        return commands.generate_abi_specification(gpa, arena, cmd_args);
    } else {
        print_usage(args[0]);
        global.fatal("unknown command: {s}", .{args[1]});
    }
}

fn print_usage(arg0: []const u8) void {
    std.log.info("{s}", .{usage});
    std.log.debug("Use {s} instead of the (stitch) command", .{arg0});
}

pub fn build(gpa: Allocator, arena: Allocator, args: []const []const u8) !void {
    _ = args;
    _ = arena;
    _ = gpa;
    var color: StdColor = .auto;
    _ = color;
}
