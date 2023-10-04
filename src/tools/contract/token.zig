const std = @import("std");
const print = @import("std").debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;

// Define an enumeration for contract token types
pub const TokenType = enum {
    PRAGMA,
    EOF,

    // Define a lookup table for token type names
    pub const TokenTypeTable = [@typeInfo(TokenType).Enum.fields.len][:0]const u8{ "pragma", "eof" };

    // Define a function to convert token type to its string representation
    pub fn str(self: TokenType) [:0]const u8 {
        return TokenTypeTable[@intFromEnum(self)];
    }
};

pub const Token = struct {
    type: TokenType,
    literal: []const u8,
};

test "TokenType.PRAGMA.str() is <<pragma>>" {
    const input = "pragma";
    try expect(eql(u8, input, TokenType.PRAGMA.str()));
}

test "TokenType.EOF.str() is <<eof>>" {
    const input = "eof";
    try expect(eql(u8, input, TokenType.EOF.str()));
}
