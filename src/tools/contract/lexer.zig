const std = @import("std");
const print = @import("std").debug.print;
const mem = std.mem;
const expect = std.testing.expect;
const eql = std.mem.eql;

const token = @import("token.zig");

pub fn Lexer() type {
    return struct {
        input: []const u8,
        // current position in input (points to current char)
        position: u8,
        // current reading position in input (after current char)
        read_position: u8,
        // current char under examination
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

        pub fn next_token(self: *Self) token.Token {
            var next: token.Token = undefined;
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
                else => {
                    next = token.Token{
                        .type = token.TokenType.EOF,
                        .literal = token.TokenType.EOF.str(),
                    };
                },
            }
            self.read_char();
            return next;
        }
    };
}

test "Lexer @This()" {
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

    for (0.., tests) |i, t| {
        _ = t;
        _ = i;
        var next = lexer.next_token();
        std.debug.print("[{s}]\n", .{next.literal});
    }
}
