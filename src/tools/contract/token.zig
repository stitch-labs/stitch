const std = @import("std");
const print = @import("std").debug.print;
const expect = std.testing.expect;
const eql = std.mem.eql;

// Define an enumeration for contract token types
pub const TokenType = enum {
    ILLEGAL,
    EOF,

    // Identifiers + literals
    IDENT,
    INT,
    COMMENT,

    // Operators
    ASSIGN,
    PLUS,
    MINUS,
    BANG,
    ASTERISK,
    SLASH,
    LT,
    GT,

    // Delimiters
    COMMA,
    SEMICOLON,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    CARRET,
    PERIOD,

    // Keywords
    PRAGMA,
    FUNCTION,
    STRUCT,
    SOLIDITY,

    // Define a lookup table for token type names
    pub const TokenTypeTable = [@typeInfo(TokenType).Enum.fields.len][:0]const u8{ "ILLEGAL", "EOF", "IDENT", "INT", "COMMENT", "=", "+", "-", "!", "*", "/", "<", ">", ",", ";", "(", ")", "{", "}", "^", ".", "pragma", "FUNCTION", "STRUCT", "solidity" };

    // Define a function to convert token type to its string representation
    pub fn str(self: TokenType) [:0]const u8 {
        return TokenTypeTable[@intFromEnum(self)];
    }

    pub fn lookup_ident(ident: []const u8) TokenType {
        if (std.mem.eql(u8, ident, TokenType.PRAGMA.str())) {
            return TokenType.PRAGMA;
        } else if (std.mem.eql(u8, ident, TokenType.SOLIDITY.str())) {
            return TokenType.SOLIDITY;
        } else if (std.mem.eql(u8, ident, TokenType.CARRET.str())) {
            return TokenType.CARRET;
        } else if (std.mem.eql(u8, ident, TokenType.PERIOD.str())) {
            return TokenType.PERIOD;
        } else {
            return TokenType.IDENT;
        }
    }
};

pub const Token = struct {
    type: TokenType,
    literal: []const u8,
};
