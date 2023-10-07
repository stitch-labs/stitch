const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

pub const Token = struct {
    type: Type,
    literal: []const u8,
};

pub const Type = enum {
    illegal,
    eof,

    // Identifiers + Literals
    identifier,
    comment,

    // Operators
    equal,
    addition_assignment,
    logical_negation,
    logical_conjunction,
    logical_disjunction,
    equality,
    inequality,
    less_than_or_equal,
    less_than,
    greater_than_or_equal,
    greater_than,
    bitwise_and,
    bitwise_or,
    bitwise_xor,
    bitwise_not,
    left_shift,
    right_shift,
    addition,
    subtraction,
    multiplication,
    division,
    modulo,
    exponentiation,

    // Delimiters
    comma,
    semicolon,
    open_parenthesis,
    close_parenthesis,
    open_curly_brace,
    close_curly_brace,
    open_square_bracket,
    close_square_bracket,
    period,

    // Keywords
    _pragma,
    _solidity,
    _contract,
    _address,
    _payable,
    _function,
    _internal,
    _external,
    _abstract,
    _after,
    _assembly,
    _auto,
    _before,
    _bool,
    _break,
    _bytes,
    _case,
    _catch,
    _constant,
    _constructor,
    _continue,
    _default,
    _delete,
    _do,
    _else,
    _emit,
    _enum,
    _error,
    _event,
    _fallback,
    _false,
    _fixed,
    _for,
    _hex,
    _if,
    _import,
    _indexed,
    _in,
    _interface,
    _is,
    _library,
    _mapping,
    _memory,
    _modifier,
    _new,
    _null,
    _override,
    _private,
    _public,
    _pure,
    _receive,
    _revert,
    _returns,
    _return,
    _selfdestruct,
    _short,
    _signed,
    _string,
    _struct,
    _super,
    _switch,
    _this,
    _throw,
    _true,
    _try,
    _type,
    _int,
    _uint,
    _unchecked,
    _unsigned,
    _using,
    _view,
    _virtual,
    _while,
    _experimental,
};

pub const TypeTable = [@typeInfo(Type).Enum.fields.len][:0]const u8{ "illegal", "eof", "identifier", "comment", "=", "+=", "!", "&&", "||", "==", "!=", "<=", "<", ">=", ">", "&", "|", "^", "~", "<<", ">>", "+", "-", "*", "/", "%", "**", ",", ";", "(", ")", "{", "}", "[", "]", ".", "pragma", "solidity", "contract", "address", "payable", "function", "internal", "external", "abstract", "after", "assembly", "auto", "before", "bool", "break", "bytes", "case", "catch", "constant", "constructor", "continue", "default", "delete", "do", "else", "emit", "enum", "error", "event", "fallback", "false", "fixed", "for", "hex", "if", "import", "indexed", "in", "interface", "is", "library", "mapping", "memory", "modifier", "new", "null", "override", "private", "public", "pure", "receive", "revert", "returns", "return", "selfdestruct", "short", "signed", "string", "struct", "super", "switch", "this", "throw", "true", "try", "type", "int", "uint", "unchecked", "unsigned", "using", "view", "virtual", "while", "experimental" };

pub fn str(self: Type) [:0]const u8 {
    return TypeTable[@intFromEnum(self)];
}

pub fn lookup_identifier(ident: []const u8) Type {
    if (std.mem.eql(u8, ident, "pragma")) {
        return Type._pragma;
    } else if (std.mem.eql(u8, ident, "solidity")) {
        return Type._solidity;
    } else if (std.mem.eql(u8, ident, "contract")) {
        return Type._contract;
    } else if (std.mem.eql(u8, ident, "address")) {
        return Type._address;
    } else if (std.mem.eql(u8, ident, "payable")) {
        return Type._payable;
    } else if (std.mem.eql(u8, ident, "function")) {
        return Type._function;
    } else if (std.mem.eql(u8, ident, "internal")) {
        return Type._internal;
    } else if (std.mem.eql(u8, ident, "external")) {
        return Type._external;
    } else if (std.mem.eql(u8, ident, "abstract")) {
        return Type._abstract;
    } else if (std.mem.eql(u8, ident, "after")) {
        return Type._after;
    } else if (std.mem.eql(u8, ident, "assembly")) {
        return Type._assembly;
    } else if (std.mem.eql(u8, ident, "auto")) {
        return Type._auto;
    } else if (std.mem.eql(u8, ident, "before")) {
        return Type._before;
    } else if (std.mem.eql(u8, ident, "bool")) {
        return Type._bool;
    } else if (std.mem.eql(u8, ident, "break")) {
        return Type._break;
    } else if (std.mem.eql(u8, ident, "bytes")) {
        return Type._bytes;
    } else if (std.mem.eql(u8, ident, "case")) {
        return Type._case;
    } else if (std.mem.eql(u8, ident, "catch")) {
        return Type._catch;
    } else if (std.mem.eql(u8, ident, "constant")) {
        return Type._constant;
    } else if (std.mem.eql(u8, ident, "constructor")) {
        return Type._constructor;
    } else if (std.mem.eql(u8, ident, "continue")) {
        return Type._continue;
    } else if (std.mem.eql(u8, ident, "default")) {
        return Type._default;
    } else if (std.mem.eql(u8, ident, "delete")) {
        return Type._delete;
    } else if (std.mem.eql(u8, ident, "do")) {
        return Type._do;
    } else if (std.mem.eql(u8, ident, "else")) {
        return Type._else;
    } else if (std.mem.eql(u8, ident, "emit")) {
        return Type._emit;
    } else if (std.mem.eql(u8, ident, "enum")) {
        return Type._enum;
    } else if (std.mem.eql(u8, ident, "error")) {
        return Type._error;
    } else if (std.mem.eql(u8, ident, "event")) {
        return Type._event;
    } else if (std.mem.eql(u8, ident, "external")) {
        return Type._external;
    } else if (std.mem.eql(u8, ident, "fallback")) {
        return Type._fallback;
    } else if (std.mem.eql(u8, ident, "false")) {
        return Type._false;
    } else if (std.mem.eql(u8, ident, "fixed")) {
        return Type._fixed;
    } else if (std.mem.eql(u8, ident, "for")) {
        return Type._for;
    } else if (std.mem.eql(u8, ident, "hex")) {
        return Type._hex;
    } else if (std.mem.eql(u8, ident, "if")) {
        return Type._if;
    } else if (std.mem.eql(u8, ident, "import")) {
        return Type._import;
    } else if (std.mem.eql(u8, ident, "indexed")) {
        return Type._indexed;
    } else if (std.mem.eql(u8, ident, "in")) {
        return Type._in;
    } else if (std.mem.eql(u8, ident, "interface")) {
        return Type._interface;
    } else if (std.mem.eql(u8, ident, "internal")) {
        return Type._internal;
    } else if (std.mem.eql(u8, ident, "is")) {
        return Type._is;
    } else if (std.mem.eql(u8, ident, "library")) {
        return Type._library;
    } else if (std.mem.eql(u8, ident, "mapping")) {
        return Type._mapping;
    } else if (std.mem.eql(u8, ident, "memory")) {
        return Type._memory;
    } else if (std.mem.eql(u8, ident, "modifier")) {
        return Type._modifier;
    } else if (std.mem.eql(u8, ident, "new")) {
        return Type._new;
    } else if (std.mem.eql(u8, ident, "null")) {
        return Type._null;
    } else if (std.mem.eql(u8, ident, "override")) {
        return Type._override;
    } else if (std.mem.eql(u8, ident, "payable")) {
        return Type._payable;
    } else if (std.mem.eql(u8, ident, "pragma")) {
        return Type._pragma;
    } else if (std.mem.eql(u8, ident, "private")) {
        return Type._private;
    } else if (std.mem.eql(u8, ident, "public")) {
        return Type._public;
    } else if (std.mem.eql(u8, ident, "pure")) {
        return Type._pure;
    } else if (std.mem.eql(u8, ident, "receive")) {
        return Type._receive;
    } else if (std.mem.eql(u8, ident, "revert")) {
        return Type._revert;
    } else if (std.mem.eql(u8, ident, "returns")) {
        return Type._returns;
    } else if (std.mem.eql(u8, ident, "return")) {
        return Type._return;
    } else if (std.mem.eql(u8, ident, "selfdestruct")) {
        return Type._selfdestruct;
    } else if (std.mem.eql(u8, ident, "short")) {
        return Type._short;
    } else if (std.mem.eql(u8, ident, "signed")) {
        return Type._signed;
    } else if (std.mem.eql(u8, ident, "string")) {
        return Type._string;
    } else if (std.mem.eql(u8, ident, "struct")) {
        return Type._struct;
    } else if (std.mem.eql(u8, ident, "super")) {
        return Type._super;
    } else if (std.mem.eql(u8, ident, "switch")) {
        return Type._switch;
    } else if (std.mem.eql(u8, ident, "this")) {
        return Type._this;
    } else if (std.mem.eql(u8, ident, "throw")) {
        return Type._throw;
    } else if (std.mem.eql(u8, ident, "true")) {
        return Type._true;
    } else if (std.mem.eql(u8, ident, "try")) {
        return Type._try;
    } else if (std.mem.eql(u8, ident, "type")) {
        return Type._type;
    } else if (std.mem.eql(u8, ident, "int")) {
        return Type._int;
    } else if (std.mem.eql(u8, ident, "uint")) {
        return Type._uint;
    } else if (std.mem.eql(u8, ident, "unchecked")) {
        return Type._unchecked;
    } else if (std.mem.eql(u8, ident, "unsigned")) {
        return Type._unsigned;
    } else if (std.mem.eql(u8, ident, "using")) {
        return Type._using;
    } else if (std.mem.eql(u8, ident, "view")) {
        return Type._view;
    } else if (std.mem.eql(u8, ident, "virtual")) {
        return Type._virtual;
    } else if (std.mem.eql(u8, ident, "while")) {
        return Type._while;
    } else if (std.mem.eql(u8, ident, "experimental")) {
        return Type._experimental;
    } else {
        return Type.identifier;
    }
}
