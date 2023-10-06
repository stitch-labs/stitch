const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

const token = @import("token.zig");

fn is_letter(ch: u8) bool {
    if (('A' <= ch and ch <= 'Z') or ('a' <= ch and ch <= 'z')) return true;
    return false;
}

fn is_whitespace(ch: u8) bool {
    if (ch == ' ') return true else if (ch == '\t') return true else if (ch == '\n') return true else if (ch == '\r') return true else return false;
}

fn is_carret(ch: u8) bool {
    if (ch == '^') return true;
    return false;
}

fn is_period(ch: u8) bool {
    if (ch == '.') return true;
    return false;
}

fn is_digit(ch: u8) bool {
    if ('0' <= ch and ch <= '9') return true;
    return false;
}

pub fn Lexer() type {
    return struct {
        input: []const u8,
        position: u8,
        read_position: u8,
        ch: u8,

        const Self = @This();

        fn read_char(self: *Self) void {
            if (self.read_position > self.input.len - 1) {
                self.ch = 0;
            } else {
                self.ch = self.input[self.read_position];
            }
            self.position = self.read_position;
            self.read_position += 1;
        }

        fn read_identifier(self: *Self) []const u8 {
            var position = self.position;
            while (is_letter(self.ch) or is_digit(self.ch)) {
                self.read_char();
            }
            return self.input[position..self.position];
        }

        fn read_number(self: *Self) []const u8 {
            var position = self.position;
            while (is_digit(self.ch)) self.read_char();
            return self.input[position..self.position];
        }

        fn read_comment(self: *Self) []const u8 {
            var position = self.position;
            while (self.ch != '\n' and self.ch != 0) {
                self.read_char();
            }
            return self.input[position..self.position];
        }

        fn skip_whitespace(self: *Self) void {
            while (is_whitespace(self.ch)) {
                self.read_char();
            }
        }

        pub fn next_token(self: *Self) token.Token {
            var next: token.Token = undefined;
            self.skip_whitespace();
            switch (self.ch) {
                '=' => {
                    next = token.Token{
                        .type = token.TokenType.ASSIGN,
                        .literal = token.TokenType.ASSIGN.str(),
                    };
                },
                '+' => {
                    next = token.Token{
                        .type = token.TokenType.PLUS,
                        .literal = token.TokenType.PLUS.str(),
                    };
                },
                ',' => {
                    next = token.Token{
                        .type = token.TokenType.COMMA,
                        .literal = token.TokenType.COMMA.str(),
                    };
                },
                ';' => {
                    next = token.Token{
                        .type = token.TokenType.SEMICOLON,
                        .literal = token.TokenType.SEMICOLON.str(),
                    };
                },
                '(' => {
                    next = token.Token{
                        .type = token.TokenType.LPAREN,
                        .literal = token.TokenType.LPAREN.str(),
                    };
                },
                ')' => {
                    next = token.Token{
                        .type = token.TokenType.RPAREN,
                        .literal = token.TokenType.RPAREN.str(),
                    };
                },
                '{' => {
                    next = token.Token{
                        .type = token.TokenType.LBRACE,
                        .literal = token.TokenType.LBRACE.str(),
                    };
                },
                '}' => {
                    next = token.Token{
                        .type = token.TokenType.RBRACE,
                        .literal = token.TokenType.RBRACE.str(),
                    };
                },
                '-' => {
                    next = token.Token{
                        .type = token.TokenType.MINUS,
                        .literal = token.TokenType.MINUS.str(),
                    };
                },
                '!' => {
                    next = token.Token{
                        .type = token.TokenType.BANG,
                        .literal = token.TokenType.BANG.str(),
                    };
                },
                '*' => {
                    next = token.Token{
                        .type = token.TokenType.ASTERISK,
                        .literal = token.TokenType.ASTERISK.str(),
                    };
                },
                '/' => {
                    self.read_char();
                    if (self.ch == '/') {
                        self.read_char();
                        next = token.Token{
                            .type = token.TokenType.COMMENT,
                            .literal = self.read_comment(),
                        };
                    } else {
                        next = token.Token{
                            .type = token.TokenType.SLASH,
                            .literal = token.TokenType.SLASH.str(),
                        };
                    }
                },
                '<' => {
                    next = token.Token{
                        .type = token.TokenType.LT,
                        .literal = token.TokenType.LT.str(),
                    };
                },
                '>' => {
                    next = token.Token{
                        .type = token.TokenType.GT,
                        .literal = token.TokenType.GT.str(),
                    };
                },
                '[' => {
                    next = token.Token{
                        .type = token.TokenType.LBRACK,
                        .literal = token.TokenType.LBRACK.str(),
                    };
                },
                ']' => {
                    next = token.Token{
                        .type = token.TokenType.RBRACK,
                        .literal = token.TokenType.RBRACK.str(),
                    };
                },
                else => {
                    if (is_letter(self.ch)) {
                        next.literal = self.read_identifier();
                        next.type = token.TokenType.lookup_ident(next.literal);
                        return next;
                    } else if (is_digit(self.ch)) {
                        next.literal = self.read_number();
                        next.type = token.TokenType.INT;
                        return next;
                    } else {
                        if (is_carret(self.ch)) {
                            next = token.Token{
                                .type = token.TokenType.CARRET,
                                .literal = "^",
                            };
                        } else if (is_period(self.ch)) {
                            next = token.Token{
                                .type = token.TokenType.PERIOD,
                                .literal = ".",
                            };
                        } else {
                            next = token.Token{
                                .type = token.TokenType.EOF,
                                .literal = "",
                            };
                        }
                    }
                },
            }
            self.read_char();
            return next;
        }
    };
}

test "Lexer" {
    std.debug.print("\n", .{});
    const input: []const u8 =
        \\// SPDX-License-Identifier: GPL-3.0
        \\pragma solidity ^0.8.0;
        \\pragma experimental ABIEncoderV2;
        \\struct S { uint a; uint[] b; T[] c; }
    ;

    var lexer = Lexer(){
        .input = input,
        .position = 0,
        .read_position = 1,
        .ch = input[0],
    };

    const tests = [_]token.Token{
        .{
            .type = token.TokenType.COMMENT,
            .literal = " SPDX-License-Identifier: GPL-3.0",
        },
        .{
            .type = token.TokenType.PRAGMA,
            .literal = "pragma",
        },
        .{
            .type = token.TokenType.SOLIDITY,
            .literal = "solidity",
        },
        .{
            .type = token.TokenType.CARRET,
            .literal = "^",
        },
        .{
            .type = token.TokenType.INT,
            .literal = "0",
        },
        .{
            .type = token.TokenType.PERIOD,
            .literal = ".",
        },
        .{
            .type = token.TokenType.INT,
            .literal = "8",
        },
        .{
            .type = token.TokenType.PERIOD,
            .literal = ".",
        },
        .{
            .type = token.TokenType.INT,
            .literal = "0",
        },
        .{
            .type = token.TokenType.SEMICOLON,
            .literal = ";",
        },
        .{
            .type = token.TokenType.PRAGMA,
            .literal = "pragma",
        },
        .{
            .type = token.TokenType.EXPERIMENTAL,
            .literal = "experimental",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "ABIEncoderV2",
        },
        .{
            .type = token.TokenType.SEMICOLON,
            .literal = ";",
        },
        .{
            .type = token.TokenType.STRUCT,
            .literal = "struct",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "S",
        },
        .{
            .type = token.TokenType.LBRACE,
            .literal = "{",
        },
        .{
            .type = token.TokenType.UINT,
            .literal = "uint",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "a",
        },
        .{
            .type = token.TokenType.SEMICOLON,
            .literal = ";",
        },
        .{
            .type = token.TokenType.UINT,
            .literal = "uint",
        },
        .{
            .type = token.TokenType.LBRACK,
            .literal = "[",
        },
        .{
            .type = token.TokenType.RBRACK,
            .literal = "]",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "b",
        },
        .{
            .type = token.TokenType.SEMICOLON,
            .literal = ";",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "T",
        },
        .{
            .type = token.TokenType.LBRACK,
            .literal = "[",
        },
        .{
            .type = token.TokenType.RBRACK,
            .literal = "]",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "c",
        },
        .{
            .type = token.TokenType.SEMICOLON,
            .literal = ";",
        },
        .{
            .type = token.TokenType.RBRACE,
            .literal = "}",
        },
    };

    for (tests) |t| {
        var next = lexer.next_token();
        std.debug.print("(({s}, {s}), ({}, {}))\n", .{ t.literal, next.literal, @intFromEnum(t.type), @intFromEnum(next.type) });
        try expect(eql(u8, t.literal, next.literal));
        try expect(@intFromEnum(t.type) == @intFromEnum(next.type));
    }
}

test "Lexer - =+(){},;" {
    std.debug.print("\n", .{});
    const input: []const u8 = "=+(){},;";

    var lexer = Lexer(){
        .input = input,
        .position = 0,
        .read_position = 1,
        .ch = input[0],
    };

    const tests = [_]token.Token{ .{
        .type = token.TokenType.ASSIGN,
        .literal = "=",
    }, .{
        .type = token.TokenType.PLUS,
        .literal = "+",
    }, .{
        .type = token.TokenType.LPAREN,
        .literal = "(",
    }, .{
        .type = token.TokenType.RPAREN,
        .literal = ")",
    }, .{
        .type = token.TokenType.LBRACE,
        .literal = "{",
    }, .{
        .type = token.TokenType.RBRACE,
        .literal = "}",
    }, .{
        .type = token.TokenType.COMMA,
        .literal = ",",
    }, .{
        .type = token.TokenType.SEMICOLON,
        .literal = ";",
    }, .{
        .type = token.TokenType.EOF,
        .literal = "",
    } };

    for (tests) |t| {
        var next = lexer.next_token();
        std.debug.print("(({s}, {s}), ({}, {}))\n", .{ t.literal, next.literal, @intFromEnum(t.type), @intFromEnum(next.type) });
        try expect(eql(u8, t.literal, next.literal));
        try expect(@intFromEnum(t.type) == @intFromEnum(next.type));
    }
}

test "Lexer - pragma solidity ^0.8.0;" {
    std.debug.print("\n", .{});
    const input: []const u8 =
        \\pragma solidity ^0.8.0;
    ;

    var lexer = Lexer(){
        .input = input,
        .position = 0,
        .read_position = 1,
        .ch = input[0],
    };

    const tests = [_]token.Token{
        .{
            .type = token.TokenType.PRAGMA,
            .literal = "pragma",
        },
        .{
            .type = token.TokenType.SOLIDITY,
            .literal = "solidity",
        },
        .{
            .type = token.TokenType.CARRET,
            .literal = "^",
        },
        .{
            .type = token.TokenType.INT,
            .literal = "0",
        },
        .{
            .type = token.TokenType.PERIOD,
            .literal = ".",
        },
        .{
            .type = token.TokenType.INT,
            .literal = "8",
        },
        .{
            .type = token.TokenType.PERIOD,
            .literal = ".",
        },
        .{
            .type = token.TokenType.INT,
            .literal = "0",
        },
        .{
            .type = token.TokenType.SEMICOLON,
            .literal = ";",
        },
    };

    for (tests) |t| {
        var next = lexer.next_token();
        std.debug.print("(({s}, {s}), ({}, {}))\n", .{ t.literal, next.literal, @intFromEnum(t.type), @intFromEnum(next.type) });
        try expect(eql(u8, t.literal, next.literal));
        try expect(@intFromEnum(t.type) == @intFromEnum(next.type));
    }
}

test "Lexer - // SPDX-License-Identifier: GPL-3.0" {
    std.debug.print("\n", .{});
    const input: []const u8 =
        \\// SPDX-License-Identifier: GPL-3.0
    ;

    var lexer = Lexer(){
        .input = input,
        .position = 0,
        .read_position = 1,
        .ch = input[0],
    };

    const tests = [_]token.Token{
        .{
            .type = token.TokenType.COMMENT,
            .literal = " SPDX-License-Identifier: GPL-3.0",
        },
    };

    for (tests) |t| {
        var next = lexer.next_token();
        std.debug.print("(({s}, {s}), ({}, {}))\n", .{ t.literal, next.literal, @intFromEnum(t.type), @intFromEnum(next.type) });
        try expect(eql(u8, t.literal, next.literal));
        try expect(@intFromEnum(t.type) == @intFromEnum(next.type));
    }
}

test "Lexer - contract Example {" {
    std.debug.print("\n", .{});
    const input: []const u8 =
        \\contract Example {
    ;

    var lexer = Lexer(){
        .input = input,
        .position = 0,
        .read_position = 1,
        .ch = input[0],
    };

    const tests = [_]token.Token{
        .{
            .type = token.TokenType.CONTRACT,
            .literal = "contract",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "Example",
        },
        .{
            .type = token.TokenType.LBRACE,
            .literal = "{",
        },
    };

    for (tests) |t| {
        var next = lexer.next_token();
        std.debug.print("(({s}, {s}), ({}, {}))\n", .{ t.literal, next.literal, @intFromEnum(t.type), @intFromEnum(next.type) });
        try expect(eql(u8, t.literal, next.literal));
        try expect(@intFromEnum(t.type) == @intFromEnum(next.type));
    }
}

test "Lexer - struct S { uint a; uint[] b; T[] c; }" {
    std.debug.print("\n", .{});
    const input: []const u8 =
        \\struct S { uint a; uint[] b; T[] c; }
    ;

    var lexer = Lexer(){
        .input = input,
        .position = 0,
        .read_position = 1,
        .ch = input[0],
    };

    const tests = [_]token.Token{
        .{
            .type = token.TokenType.STRUCT,
            .literal = "struct",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "S",
        },
        .{
            .type = token.TokenType.LBRACE,
            .literal = "{",
        },
        .{
            .type = token.TokenType.UINT,
            .literal = "uint",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "a",
        },
        .{
            .type = token.TokenType.SEMICOLON,
            .literal = ";",
        },
        .{
            .type = token.TokenType.UINT,
            .literal = "uint",
        },
        .{
            .type = token.TokenType.LBRACK,
            .literal = "[",
        },
        .{
            .type = token.TokenType.RBRACK,
            .literal = "]",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "b",
        },
        .{
            .type = token.TokenType.SEMICOLON,
            .literal = ";",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "T",
        },
        .{
            .type = token.TokenType.LBRACK,
            .literal = "[",
        },
        .{
            .type = token.TokenType.RBRACK,
            .literal = "]",
        },
        .{
            .type = token.TokenType.IDENT,
            .literal = "c",
        },
        .{
            .type = token.TokenType.SEMICOLON,
            .literal = ";",
        },
        .{
            .type = token.TokenType.RBRACE,
            .literal = "}",
        },
    };

    for (tests) |t| {
        var next = lexer.next_token();
        std.debug.print("(({s}, {s}), ({}, {}))\n", .{ t.literal, next.literal, @intFromEnum(t.type), @intFromEnum(next.type) });
        try expect(eql(u8, t.literal, next.literal));
        try expect(@intFromEnum(t.type) == @intFromEnum(next.type));
    }
}
