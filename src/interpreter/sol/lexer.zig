const std = @import("std");

const expect = std.testing.expect;
const eql = std.mem.eql;

const language = @import("language.zig");
const util = @import("../../../util.zig");

const max_word_size = 15;
const test_allocator = std.testing.allocator;

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

        fn peek_char(self: *Self) u8 {
            if (self.read_position > self.input.len - 1) {
                return 0;
            } else {
                return self.input[self.read_position];
            }
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

        pub fn next_token(self: *Self) language.Token {
            var next: language.Token = undefined;
            self.skip_whitespace();
            switch (self.ch) {
                '=' => {
                    if (self.peek_char() == '=') {
                        self.read_char();
                        next = language.Token{
                            .type = language.Type.equality,
                            .literal = language.str(language.Type.equality),
                        };
                    } else {
                        next = language.Token{
                            .type = language.Type.equal,
                            .literal = language.str(language.Type.equal),
                        };
                    }
                },
                '+' => {
                    if (self.peek_char() == '=') {
                        self.read_char();
                        next = language.Token{
                            .type = language.Type.addition_assignment,
                            .literal = language.str(language.Type.addition_assignment),
                        };
                    } else {
                        next = language.Token{
                            .type = language.Type.addition,
                            .literal = language.str(language.Type.addition),
                        };
                    }
                },
                ',' => {
                    next = language.Token{
                        .type = language.Type.comma,
                        .literal = language.str(language.Type.comma),
                    };
                },
                ';' => {
                    next = language.Token{
                        .type = language.Type.semicolon,
                        .literal = language.str(language.Type.semicolon),
                    };
                },
                '(' => {
                    next = language.Token{
                        .type = language.Type.open_parenthesis,
                        .literal = language.str(language.Type.open_parenthesis),
                    };
                },
                ')' => {
                    next = language.Token{
                        .type = language.Type.close_parenthesis,
                        .literal = language.str(language.Type.close_parenthesis),
                    };
                },
                '{' => {
                    next = language.Token{
                        .type = language.Type.open_curly_brace,
                        .literal = language.str(language.Type.open_curly_brace),
                    };
                },
                '}' => {
                    next = language.Token{
                        .type = language.Type.close_curly_brace,
                        .literal = language.str(language.Type.close_curly_brace),
                    };
                },
                '-' => {
                    next = language.Token{
                        .type = language.Type.subtraction,
                        .literal = language.str(language.Type.subtraction),
                    };
                },
                '!' => {
                    if (self.peek_char() == '=') {
                        self.read_char();
                        next = language.Token{
                            .type = language.Type.inequality,
                            .literal = language.str(language.Type.inequality),
                        };
                    } else {
                        next = language.Token{
                            .type = language.Type.logical_negation,
                            .literal = language.str(language.Type.logical_negation),
                        };
                    }
                },
                '*' => {
                    next = language.Token{
                        .type = language.Type.multiplication,
                        .literal = language.str(language.Type.multiplication),
                    };
                },
                '/' => {
                    if (self.peek_char() == '/') {
                        self.read_char();
                        self.read_char();
                        next = language.Token{
                            .type = language.Type.comment,
                            .literal = self.read_comment(),
                        };
                    } else {
                        next = language.Token{
                            .type = language.Type.division,
                            .literal = language.str(language.Type.division),
                        };
                    }
                },
                '<' => {
                    if (self.peek_char() == '=') {
                        self.read_char();
                        next = language.Token{
                            .type = language.Type.less_than_or_equal,
                            .literal = language.str(language.Type.less_than_or_equal),
                        };
                    } else if (self.peek_char() == '<') {
                        self.read_char();
                        next = language.Token{
                            .type = language.Type.left_shift,
                            .literal = language.str(language.Type.left_shift),
                        };
                    } else {
                        next = language.Token{
                            .type = language.Type.less_than,
                            .literal = language.str(language.Type.less_than),
                        };
                    }
                },
                '>' => {
                    if (self.peek_char() == '=') {
                        self.read_char();
                        next = language.Token{
                            .type = language.Type.greater_than_or_equal,
                            .literal = language.str(language.Type.greater_than_or_equal),
                        };
                    } else if (self.peek_char() == '>') {
                        self.read_char();
                        next = language.Token{
                            .type = language.Type.right_shift,
                            .literal = language.str(language.Type.right_shift),
                        };
                    } else {
                        next = language.Token{
                            .type = language.Type.greater_than,
                            .literal = language.str(language.Type.greater_than),
                        };
                    }
                },
                '[' => {
                    next = language.Token{
                        .type = language.Type.open_square_bracket,
                        .literal = language.str(language.Type.open_square_bracket),
                    };
                },
                ']' => {
                    next = language.Token{
                        .type = language.Type.close_square_bracket,
                        .literal = language.str(language.Type.close_square_bracket),
                    };
                },
                '&' => {
                    next = language.Token{
                        .type = language.Type.bitwise_and,
                        .literal = language.str(language.Type.bitwise_and),
                    };
                },
                '|' => {
                    next = language.Token{
                        .type = language.Type.bitwise_or,
                        .literal = language.str(language.Type.bitwise_or),
                    };
                },
                '^' => {
                    next = language.Token{
                        .type = language.Type.bitwise_xor,
                        .literal = language.str(language.Type.bitwise_xor),
                    };
                },
                '~' => {
                    next = language.Token{
                        .type = language.Type.bitwise_not,
                        .literal = language.str(language.Type.bitwise_not),
                    };
                },
                '%' => {
                    next = language.Token{
                        .type = language.Type.modulo,
                        .literal = language.str(language.Type.modulo),
                    };
                },
                '.' => {
                    next = language.Token{
                        .type = language.Type.period,
                        .literal = language.str(language.Type.period),
                    };
                },
                else => {
                    if (is_letter(self.ch)) {
                        next.literal = self.read_identifier();
                        next.type = language.lookup_identifier(next.literal);
                        return next;
                    } else if (is_digit(self.ch)) {
                        next.literal = self.read_number();
                        next.type = language.Type._uint;
                        return next;
                    } else {
                        next = language.Token{
                            .type = language.Type.eof,
                            .literal = "",
                        };
                    }
                },
            }
            self.read_char();
            return next;
        }
    };
}

test "Lexer Single Operators" {
    std.debug.print("\n", .{});

    const input: []const u8 = "=+()-{},;!|&^<>";

    var lexer = Lexer(){
        .input = input,
        .position = 0,
        .read_position = 1,
        .ch = input[0],
    };

    const tests = [_]language.Token{
        .{
            .type = language.Type.equal,
            .literal = "=",
        },
        .{
            .type = language.Type.addition,
            .literal = "+",
        },
        .{
            .type = language.Type.open_parenthesis,
            .literal = "(",
        },
        .{
            .type = language.Type.close_parenthesis,
            .literal = ")",
        },
        .{
            .type = language.Type.subtraction,
            .literal = "-",
        },
        .{
            .type = language.Type.open_curly_brace,
            .literal = "{",
        },
        .{
            .type = language.Type.close_curly_brace,
            .literal = "}",
        },
        .{
            .type = language.Type.comma,
            .literal = ",",
        },
        .{
            .type = language.Type.semicolon,
            .literal = ";",
        },
        .{
            .type = language.Type.logical_negation,
            .literal = "!",
        },
        .{
            .type = language.Type.bitwise_or,
            .literal = "|",
        },
        .{
            .type = language.Type.bitwise_and,
            .literal = "&",
        },
        .{
            .type = language.Type.bitwise_xor,
            .literal = "^",
        },
        .{
            .type = language.Type.less_than,
            .literal = "<",
        },
        .{
            .type = language.Type.greater_than,
            .literal = ">",
        },
    };

    for (tests) |t| {
        var next = lexer.next_token();

        std.debug.print("(({s}, {s}), ({}, {}))\n", .{ t.literal, next.literal, @intFromEnum(t.type), @intFromEnum(next.type) });

        try expect(eql(u8, t.literal, next.literal));
        try expect(@intFromEnum(t.type) == @intFromEnum(next.type));
    }
}

test "Lexer Double Operators" {
    std.debug.print("\n", .{});

    const input = "== != <= >= << >> +=";

    var lexer = Lexer(){
        .input = input,
        .position = 0,
        .read_position = 1,
        .ch = input[0],
    };

    const tests = [_]language.Token{
        .{
            .type = language.Type.equality,
            .literal = "==",
        },
        .{
            .type = language.Type.inequality,
            .literal = "!=",
        },
        .{
            .type = language.Type.less_than_or_equal,
            .literal = "<=",
        },
        .{
            .type = language.Type.greater_than_or_equal,
            .literal = ">=",
        },
        .{
            .type = language.Type.left_shift,
            .literal = "<<",
        },
        .{
            .type = language.Type.right_shift,
            .literal = ">>",
        },
        .{
            .type = language.Type.addition_assignment,
            .literal = "+=",
        },
    };

    for (tests) |t| {
        var next = lexer.next_token();

        std.debug.print("(({s}, {s}), ({}, {}))\n", .{ t.literal, next.literal, @intFromEnum(t.type), @intFromEnum(next.type) });

        try expect(eql(u8, t.literal, next.literal));
        try expect(@intFromEnum(t.type) == @intFromEnum(next.type));
    }
}

test "Lexer Full Solidity Code Example" {
    std.debug.print("\n", .{});
    const input: []const u8 =
        \\// SPDX-License-Identifier: GPL-3.0
        \\pragma solidity ^0.8.0;
        \\pragma experimental ABIEncoderV2;
        \\
        \\contract Example {
        \\  struct S { uint a; uint[] b; T[] c; }
        \\  struct T { uint x; uint y; }
        \\  function f(S memory, T memory, uint) public pure {}
        \\  function g() public pure returns (S memory, T memory, uint) {}
        \\}
    ;
    var lexer = Lexer(){
        .input = input,
        .position = 0,
        .read_position = 1,
        .ch = input[0],
    };

    const tests = [_]language.Token{
        .{
            .type = language.Type.comment,
            .literal = " SPDX-License-Identifier: GPL-3.0",
        },
        .{
            .type = language.Type._pragma,
            .literal = "pragma",
        },
        .{
            .type = language.Type._solidity,
            .literal = "solidity",
        },
        .{
            .type = language.Type.bitwise_xor,
            .literal = "^",
        },
        .{
            .type = language.Type._uint,
            .literal = "0",
        },
        .{
            .type = language.Type.period,
            .literal = ".",
        },
        .{
            .type = language.Type._uint,
            .literal = "8",
        },
        .{
            .type = language.Type.period,
            .literal = ".",
        },
        .{
            .type = language.Type._uint,
            .literal = "0",
        },
        .{
            .type = language.Type.semicolon,
            .literal = ";",
        },
        .{
            .type = language.Type._pragma,
            .literal = "pragma",
        },
        .{
            .type = language.Type._experimental,
            .literal = "experimental",
        },
        .{
            .type = language.Type.identifier,
            .literal = "ABIEncoderV2",
        },
        .{
            .type = language.Type.semicolon,
            .literal = ";",
        },
        .{
            .type = language.Type._contract,
            .literal = "contract",
        },
        .{
            .type = language.Type.identifier,
            .literal = "Example",
        },
        .{
            .type = language.Type.open_curly_brace,
            .literal = "{",
        },
        .{
            .type = language.Type._struct,
            .literal = "struct",
        },
        .{
            .type = language.Type.identifier,
            .literal = "S",
        },
        .{
            .type = language.Type.open_curly_brace,
            .literal = "{",
        },
        .{
            .type = language.Type._uint,
            .literal = "uint",
        },
        .{
            .type = language.Type.identifier,
            .literal = "a",
        },
        .{
            .type = language.Type.semicolon,
            .literal = ";",
        },
        .{
            .type = language.Type._uint,
            .literal = "uint",
        },
        .{
            .type = language.Type.open_square_bracket,
            .literal = "[",
        },
        .{
            .type = language.Type.close_square_bracket,
            .literal = "]",
        },
        .{
            .type = language.Type.identifier,
            .literal = "b",
        },
        .{
            .type = language.Type.semicolon,
            .literal = ";",
        },
        .{
            .type = language.Type.identifier,
            .literal = "T",
        },
        .{
            .type = language.Type.open_square_bracket,
            .literal = "[",
        },
        .{
            .type = language.Type.close_square_bracket,
            .literal = "]",
        },
        .{
            .type = language.Type.identifier,
            .literal = "c",
        },
        .{
            .type = language.Type.semicolon,
            .literal = ";",
        },
        .{
            .type = language.Type.close_curly_brace,
            .literal = "}",
        },
        .{
            .type = language.Type._struct,
            .literal = "struct",
        },
        .{
            .type = language.Type.identifier,
            .literal = "T",
        },
        .{
            .type = language.Type.open_curly_brace,
            .literal = "{",
        },
        .{
            .type = language.Type._uint,
            .literal = "uint",
        },
        .{
            .type = language.Type.identifier,
            .literal = "x",
        },
        .{
            .type = language.Type.semicolon,
            .literal = ";",
        },
        .{
            .type = language.Type._uint,
            .literal = "uint",
        },
        .{
            .type = language.Type.identifier,
            .literal = "y",
        },
        .{
            .type = language.Type.semicolon,
            .literal = ";",
        },
        .{
            .type = language.Type.close_curly_brace,
            .literal = "}",
        },
        .{
            .type = language.Type._function,
            .literal = "function",
        },
        .{
            .type = language.Type.identifier,
            .literal = "f",
        },
        .{
            .type = language.Type.open_parenthesis,
            .literal = "(",
        },
        .{
            .type = language.Type.identifier,
            .literal = "S",
        },
        .{
            .type = language.Type._memory,
            .literal = "memory",
        },
        .{
            .type = language.Type.comma,
            .literal = ",",
        },
        .{
            .type = language.Type.identifier,
            .literal = "T",
        },
        .{
            .type = language.Type._memory,
            .literal = "memory",
        },
        .{
            .type = language.Type.comma,
            .literal = ",",
        },
        .{
            .type = language.Type._uint,
            .literal = "uint",
        },
        .{
            .type = language.Type.close_parenthesis,
            .literal = ")",
        },
        .{
            .type = language.Type._public,
            .literal = "public",
        },
        .{
            .type = language.Type._pure,
            .literal = "pure",
        },
        .{
            .type = language.Type.open_curly_brace,
            .literal = "{",
        },
        .{
            .type = language.Type.close_curly_brace,
            .literal = "}",
        },
        .{
            .type = language.Type._function,
            .literal = "function",
        },
        .{
            .type = language.Type.identifier,
            .literal = "g",
        },
        .{
            .type = language.Type.open_parenthesis,
            .literal = "(",
        },
        .{
            .type = language.Type.close_parenthesis,
            .literal = ")",
        },
    };

    var token_count: usize = 0;
    for (tests) |t| {
        var next = lexer.next_token();

        const type_str = language.str(next.type);
        const literal_str = next.literal;

        const padding_count = util.max(0, max_word_size - type_str.len);
        const _padding = try util.padding_runtime(test_allocator, padding_count);
        defer test_allocator.free(_padding);

        std.debug.print(
            \\{d:>2}: Type:{s}{s}Literal: {s}
            \\
        , .{
            token_count,
            type_str,
            _padding,
            literal_str,
        });
        token_count += 1;

        try expect(eql(u8, t.literal, next.literal));
        try expect(@intFromEnum(t.type) == @intFromEnum(next.type));
    }
}
