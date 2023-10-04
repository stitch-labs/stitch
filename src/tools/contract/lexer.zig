const std = @import("std");
const print = @import("std").debug.print;
const mem = std.mem;
const expect = std.testing.expect;
const eql = std.mem.eql;

const token = @import("token.zig");

pub const Lexer = struct {
    input: []const u8,
    // current position in input (points to current char)
    position: u8,
    // current reading position in input (after current char)
    read_position: u8,
    // current char under examination
    ch: []const u8,

    fn read_char(self: *const Lexer) void {
        if (self.read_position > self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    pub fn next_token(self: *const Lexer) token.Token {
        var next = token.Token{
            .type = token.TokenType.EOF,
            .literal = token.TokenType.EOF.str(),
        };
        if (mem.eql(u8, self.ch, token.TokenType.PRAGMA.str())) {
            next = token.Token{
                .type = token.TokenType.PRAGMA,
                .literal = self.ch,
            };
        }
        self.read_char();
        return next;
    }
};

test "Test NextToken" {
    const input = "pragma";
    const tests = [_]token.Token{.{
        .type = token.TokenType.PRAGMA,
        .literal = "pragma",
    }};

    const lexer = Lexer{
        .input = input,
        .position = 0,
        .read_position = 0,
        .ch = "",
    };

    for (0.., tests) |i, t| {
        _ = t;
        _ = i;
        var next = lexer.next_token();
        std.debug.print("[{s}]\n", .{next.literal});
    }
}
