const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

const language = @import("language.zig");

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

        pub fn next_token(self: *Self) language.Token {
            var next: language.Token = undefined;
            self.skip_whitespace();
            switch (self.ch) {
                '=' => {
                    next = language.Token{
                        .type = language.Type.equality,
                        .literal = language.str(language.Type.equality),
                    };
                },
                '+' => {
                    next = language.Token{
                        .type = language.Type.addition,
                        .literal = language.str(language.Type.addition),
                    };
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
                    next = language.Token{
                        .type = language.Type.logical_negation,
                        .literal = language.str(language.Type.logical_negation),
                    };
                },
                '*' => {
                    next = language.Token{
                        .type = language.Type.multiplication,
                        .literal = language.str(language.Type.multiplication),
                    };
                },
                '/' => {
                    self.read_char();
                    if (self.ch == '/') {
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
                    next = language.Token{
                        .type = language.Type.less_than,
                        .literal = language.str(language.Type.less_than),
                    };
                },
                '>' => {
                    next = language.Token{
                        .type = language.Type.greater_than,
                        .literal = language.str(language.Type.greater_than),
                    };
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
                // '<<' => { next = language.Token{ .type = language.Type.left_shift, .literal = language.str(language.Type.left_shift), }; },
                // '>>' => { next = language.Token{ .type = language.Type.right_shift, .literal = language.str(language.Type.right_shift), }; },
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
                // '**' => { next = language.Token{ .type = language.Type.exponentiation, .literal = language.str(language.Type.exponentiation), }; },
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
    };

    for (tests) |t| {
        var next = lexer.next_token();
        std.debug.print("(({s}, {s}), ({}, {}))\n", .{ t.literal, next.literal, @intFromEnum(t.type), @intFromEnum(next.type) });
        try expect(eql(u8, t.literal, next.literal));
        try expect(@intFromEnum(t.type) == @intFromEnum(next.type));
    }
}
