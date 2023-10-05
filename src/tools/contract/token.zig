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

    // Operators
    ASSIGN,
    PLUS,

    // Delimiters
    COMMA,
    SEMICOLON,
    LPAREN,
    RPAREN,
    LBRACE,
    RBRACE,
    CARRET,

    // Keywords
    PRAGMA,
    FUNCTION,
    STRUCT,
    SOLIDITY,

    // Define a lookup table for token type names
    pub const TokenTypeTable = [@typeInfo(TokenType).Enum.fields.len][:0]const u8{ "ILLEGAL", "EOF", "IDENT", "INT", "=", "+", ",", ";", "(", ")", "{", "}", "^", "pragma", "FUNCTION", "STRUCT", "solidity" };

    // Define a function to convert token type to its string representation
    pub fn str(self: TokenType) [:0]const u8 {
        return TokenTypeTable[@intFromEnum(self)];
    }
};

pub const KeywordType = enum {
    PRAGMA,
    FUNCTION,
    STRUCT,
    SOLIDITY,

    pub const KeywordTypeTable = [@typeInfo(KeywordType).Enum.fields.len][:0]const u8{ "pragma", "function", "struct", "solidity" };

    pub fn str(self: KeywordType) [:0]const u8 {
        return KeywordTypeTable[@intFromEnum(self)];
    }

    pub fn lookup_ident(ident: []const u8) TokenType {
        if (std.mem.eql([]const u8, ident, KeywordType.PRAGMA.str())) {
            return TokenType.PRAGMA;
        } else {
            return TokenType.IDENT;
        }
        // switch (ident) {
        //     KeywordType.PRAGMA => return TokenType.PRAGMA,
        //     KeywordType.FUNCTION => return TokenType.FUNCTION,
        //     KeywordType.STRUCT => return TokenType.STRUCT,
        //     KeywordType.SOLIDITY => return TokenType.STRUCT,
        //     else => return TokenType.IDENT,
        // }
    }
};

pub const Token = struct {
    type: TokenType,
    literal: []const u8,
};

// var keywords = map[string]TokenType{
//     "fn": FUNCTION,
//     "let": LET,
// }

// func LookupIdent(ident string) TokenType { if tok, ok := keywords[ident]; ok {
// return tok }
// return IDENT }
