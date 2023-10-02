//This file is auto-generated by tools/gen_abi_spec.zig
const Version = @import("std").SemanticVersion;
pub const AbiFunctionType = enum(u8) {
    function = 0x0,
};
pub const AbiComponentType = enum(u8) {
    tuple = 0x10,
    uint256 = 0x11,
};
const AbiFunction = struct {
    name: []const u8,
    type: AbiFunctionType,
    inputs: []AbiComponent,
    outputs: []AbiComponent,
};
const AbiComponent = struct {
    name: []const u8,
    type: AbiComponentType,
    components: []AbiComponent,
};

