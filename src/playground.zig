const std = @import("std");
const testing = std.testing;
const expect = std.testing.expect;
const expectEqual = std.testing.expectEqual;
const eql = std.mem.eql;

const TokenType = enum {
    FUNCTION,
    LET,
    IDENTIFIER,
};

const keywords = std.StringHashMap(TokenType).init(std.testing.allocator);

pub fn lookup_identifier(identifier: []const u8) TokenType {
    const tok: ?TokenType = keywords.get(identifier);
    if (tok) |t| return t;
    return TokenType.IDENTIFIER;
}

test "lookup_identifier basic usage w no mappings" {
    var value: TokenType = lookup_identifier("fn");
    try expect(@intFromEnum(TokenType.IDENTIFIER) == @intFromEnum(value));
}

test "lookup_identifier basic usage w mappings" {
    try keywords.put("fn", TokenType.FUNCTION);
    var value: TokenType = lookup_identifier("fn");
    try expect(@intFromEnum(TokenType.FUNCTION) == @intFromEnum(value));
}
