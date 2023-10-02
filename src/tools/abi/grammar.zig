const std = @import("std");
const print = @import("std").debug.print;
const expect = std.testing.expect;

pub const CoreRegistry = struct {
    magic_number: []const u8 = "ExampleContract",
    major_version: u32 = 0,
    minor_version: u32 = 8,
    revision: u32 = 0,

    contract_abi: []AbiFunction,
};

const AbiComponent = struct {
    name: []const u8,
    type: AbiComponentType,
    components: []AbiComponent,
};

const AbiFunction = struct {
    name: []const u8,
    type: AbiFunctionType,
    inputs: []AbiComponent,
    outputs: []AbiComponent,
};

pub const AbiFunctionType = enum(u8) {
    function = 0x0,
};

pub const AbiComponentType = enum(u8) {
    tuple = 0x10,
    uint256 = 0x11,
};

test "Test intFromEnum function for AbiComponentType.tuple" {
    try expect(@intFromEnum(AbiComponentType.tuple) == 16);
}

test "Test intFromEnum function for AbiComponentType.uint256" {
    try expect(@intFromEnum(AbiComponentType.uint256) == 17);
}

test "Test AbiInputList initialization and item types" {
    const allocator = std.heap.page_allocator;
    var abi_input_list = std.ArrayList(AbiComponent).init(allocator);
    defer abi_input_list.deinit();

    try abi_input_list.append(.{ .name = "s", .type = AbiComponentType.tuple, .components = &[_]AbiComponent{} });
    try abi_input_list.append(.{ .name = "t", .type = AbiComponentType.tuple, .components = &[_]AbiComponent{} });
    try abi_input_list.append(.{ .name = "a", .type = AbiComponentType.uint256, .components = &[_]AbiComponent{} });

    try expect(abi_input_list.items[0].type == AbiComponentType.tuple);
    try expect(abi_input_list.items[1].type == AbiComponentType.tuple);
    try expect(abi_input_list.items[2].type == AbiComponentType.uint256);
}

test "Test AbiList initialization and item type" {
    const allocator = std.heap.page_allocator;
    var abi_list = std.ArrayList(AbiFunction).init(allocator);
    defer abi_list.deinit();

    var abi_input_list = std.ArrayList(AbiComponent).init(allocator);
    var abi_output_list = std.ArrayList(AbiComponent).init(allocator);

    try abi_list.append(.{ .name = "f", .type = AbiFunctionType.function, .inputs = abi_input_list.items, .outputs = abi_output_list.items });

    try expect(abi_list.items[0].type == AbiFunctionType.function);
}
