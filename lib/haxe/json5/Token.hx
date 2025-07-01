package haxe.json5;

enum Token {
    TId(raw: String, pos: TokenPos);
    TString(string: String, pos: TokenPos);
    TLBracket(pos: TokenPos);
    TRBracket(pos: TokenPos);
    TLBrace(pos: TokenPos);
    TRBrace(pos: TokenPos);
    TComma(pos: TokenPos);
    TColon(pos: TokenPos);
}

@:structInit class TokenPos {
    public var line: Int;
    public var column: Int;

    public function toString(): String {
        return TokenHelper.formatPos(line, column);
    }
}

class TokenHelper {
    public static function getReservedToken(code: Int, pos: TokenPos): Token {
        return switch (code) {
            case '{'.code: TLBrace(pos);
            case '}'.code: TRBrace(pos);
            case '['.code: TLBracket(pos);
            case ']'.code: TRBracket(pos);
            case ','.code: TComma(pos);
            case ':'.code: TColon(pos);
            default: throw 'This shouldn\'t be reachable.';
        }
    }

    public static function tokenToString(token: Token): String {
        return switch (token) {
            case TId(raw, _): raw;
            case TString(string, _): string;
            case TLBrace(_): '{';
            case TRBrace(_): '}';
            case TLBracket(_): '[';
            case TRBracket(_): ']';
            case TComma(_): ',';
            case TColon(_): ':';
        }
    }

    public static function extractPos(token: Token): TokenPos {
        return switch (token) {
            case TId(_, pos): pos;
            case TString(_, pos): pos;
            case TLBrace(pos): pos;
            case TRBrace(pos): pos;
            case TLBracket(pos): pos;
            case TRBracket(pos): pos;
            case TComma(pos): pos;
            case TColon(pos): pos;
        }
    }

    public static function formatPos(line: Int, column: Int): String {
        return '(line ${line}, column ${column})';
    }

    public static function isTokenReserved(code: Int): Bool {
        return code == '{'.code || code == '}'.code
            || code == '['.code || code == ']'.code
            || code == ','.code || code == ':'.code;
    }

    public static function isTokenWhitespace(code: Int): Bool {
        return code == ' '.code || code == '\n'.code || code == '\t'.code || code == '\r'.code;
    }

    public static function isTokenFromIdentifier(code: Int): Bool {
        return !isTokenReserved(code) && !isTokenWhitespace(code) && code != "'".code && code != '"'.code && code != '/'.code;
    }
}
