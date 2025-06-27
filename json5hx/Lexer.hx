package json5hx;

import json5hx.Token;

class Lexer {
    var content: String;
    var output: Array<Token>;

    var currChar: Int = 0;
    var currLine: Int = 1;
    var currColumn: Int = 1;

    @:allow(json5hx.Json5)
    function new(content: String): Void {
        this.content = content;
    }

    public function tokenize(): Array<Token> {
        output = [];

        while (currChar < content.length) {
            var charCode: Int = currentChar();
            var token: Token = resolveToken(charCode);

            if (token != null)
                output.push(token);

            consume();
        }

        return output;
    }

    function resolveToken(charCode: Int): Token {
        switch (charCode) {
            case (TokenHelper.isTokenReserved(_) => true):
                return TokenHelper.getReservedToken(charCode, currentPos());

            case (TokenHelper.isTokenWhitespace(_) => true):
                return null;

            case '"'.code:
                // capture all characters between the current and the next double quote
                return parseString('"'.code);

            case "'".code:
                // capture all characters between the current and the next single quote
                return parseString("'".code);

            case '/'.code:
                // single-line/multi-line comment
                skipComment();
                return null;

            default:
                return parseIdentifier();
        }
    }

    function parseString(quotationMark: Int): Token {
        consume();

        var buf: StringBuf = new StringBuf();
        var formFeedOffset: Int = 0;

        var originLine: Int = currLine;
        var originColumn: Int = currColumn;

        while (true) {
            var code: Int = currentChar();

            if (StringTools.isEof(code))
                throw 'Unclosed string ' + TokenHelper.formatPos(originLine, originColumn);

            if (code == quotationMark)
                break;

            switch (code) {
                case '\\'.code:
                    // handle escape sequence
                    consume();
                    code = currentChar();
                    consume();

                    switch (code) {
                        case 'x'.code:
                            buf.addChar(parseHexadecimalCharacter(2, quotationMark));

                        case 'u'.code:
                            buf.addChar(parseHexadecimalCharacter(4, quotationMark));

                        case 'b'.code:
                            var flushed: String = buf.toString();
                            if (flushed.length > 0) {
                                buf = new StringBuf();
                                buf.add(flushed.substring(0, flushed.length - 1));
                            }

                        case 'f'.code, 'v'.code:
                            buf.addChar('\n'.code);
                            for (i in 0...formFeedOffset) {
                                buf.addChar(' '.code);
                            }

                        case 'n'.code:
                            buf.addChar('\n'.code);
                            formFeedOffset = 0;

                        case 'r'.code:
                            buf.addChar('\r'.code);

                        case 't'.code:
                            buf.addChar('\t'.code);

                        case '0'.code:
                            buf.addChar(0);

                            var followingChar: Int = currentChar();
                            if (isDigit(followingChar))
                                throw 'Digit cannot follow \\0 ' + currentPos();
                        
                        case (isLineTerminator(_) => true):
                            while (isLineTerminator(currentChar())) {
                                consume();
                            }

                        case ((_ < '1'.code || code > '9'.code) => true):
                            buf.addChar(code);

                        default:
                            // do nothing
                    }

                case '\n'.code, '\r'.code:
                    throw 'String cannot be continued on a newline without reverse solidus (\\) ' + currentPos();

                default:
                    if (code == 0x2028)
                        Json5.warning('Unicode code point U+2028 (Line Separator) found unescaped ' + TokenHelper.formatPos(currLine, currColumn));
                    else if (code == 0x2029)
                        Json5.warning('Unicode code point U+2029 (Paragraph Separator) found unescaped ' + TokenHelper.formatPos(currLine, currColumn));

                    buf.addChar(code);
                    consume();
            }

            formFeedOffset++;
        }

        return TString(buf.toString(), currentPos());
    }

    function parseIdentifier(): Token {
        var buf: StringBuf = new StringBuf();

        while (true) {
            buf.addChar(currentChar());

            var next: Int = peek();

            if (StringTools.isEof(next))
                break;

            if (!TokenHelper.isTokenFromIdentifier(next))
                break;
            
            consume();
        }

        return TId(buf.toString(), currentPos());
    }

    function parseHexadecimalCharacter(digits: Int, quotationMark: Int): Int {
        var extractedHexadecimal: StringBuf = new StringBuf();

        for (i in 0...digits) {
            var code: Int = currentChar();
            if (StringTools.isEof(code) || code == quotationMark)
                throw 'Expected ' + digits + ' hexadecimal digits ' + currentPos();

            if (!isHexadecimalDigit(code))
                throw 'Invalid hexadecimal digit "' + String.fromCharCode(code) + '" ' + currentPos();

            extractedHexadecimal.addChar(code);
            consume();
        }

        return Std.parseInt('0x' + extractedHexadecimal.toString());
    }

    function skipComment(): Void {
        var nextCode: Int = peek();

        switch (nextCode) {
            case '/'.code:
                // single-line comment
                consume();
                consume();
                while (true) {
                    var code: Int = currentChar();
                    if (code == '\n'.code || StringTools.isEof(code))
                        break;
                    consume();
                }
            
            case '*'.code:
                // multi-line comment
                var originLine: Int = currLine;
                var originColumn: Int = currColumn;
                consume();
                consume();

                while (true) {
                    var code: Int = currentChar();
                    if (StringTools.isEof(code))
                        throw 'Unclosed multi-line comment ' + TokenHelper.formatPos(originLine, originColumn);

                    consume();
                    if (code == '*'.code && currentChar() == '/'.code)
                        break;
                    else if (code == '/'.code && currentChar() == '*'.code)
                        throw 'Multi-line comments cannot nest ' + currentPos();
                }
            
            default:
                throw 'Invalid comment declaration ' + currentPos();
        }
    }

    function consume(): Void {
        var currentCode: Int = currentChar();
        if (currentCode == '\n'.code) {
            currLine++;
            currColumn = 1;
        } else {
            currColumn++;
        }
        currChar++;
    }

    function isLineTerminator(code: Int): Bool {
        return code == '\n'.code || code == '\r'.code || code == 0x2028 || code == 0x2029;
    }

    function isHexadecimalDigit(code: Int): Bool {
        return (code >= 'a'.code && code <= 'f'.code) || (code >= 'A'.code && code <= 'F'.code) || isDigit(code);
    }

    function isDigit(code: Int): Bool {
        return code >= '0'.code && code <= '9'.code;
    }

    inline function currentPos(): TokenPos {
        return {line: currLine, column: currColumn};
    }

    inline function currentChar(): Int {
        return StringTools.fastCodeAt(content, currChar);
    }

    inline function peek(): Int {
        return StringTools.fastCodeAt(content, currChar + 1);
    }
}
