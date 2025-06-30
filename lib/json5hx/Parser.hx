package json5hx;

import json5hx.Token;

using StringTools;

class Parser {
    var tokens: Array<Token>;
    var currToken: Int = 0;

    var numberRegex: EReg = new EReg("^(?:[+-]?(?:(?:[1-9]\\d*|0)(?:\\.\\d*)?|\\.\\d+)(?:[Ee][+-]?\\d+)?)$", "");
    var hexadecimalRegex: EReg = new EReg("^[+-]?(?:0x)[0-9a-f]+$", "i");

    @:allow(json5hx.Json5)
    function new(tokens: Array<Token>): Void {
        this.tokens = tokens;
    }
    
    public function parse(): Any {
        var output: Any = parseValue();

        if (currToken < tokens.length) {
            invalidEof();
        }

        return output;
    }

    function parseValue(): Any {
        var token: Token = tokens[currToken];

        if (token == null)
            throw 'Premature document end';

        switch (token) {
            case TLBrace(_):
                return parseObject();

            case TLBracket(_):
                return parseArray();
            
            case TString(string, _):
                currToken++;
                return string;
            
            case TId(raw, pos):
                currToken++;
                return parseIdentifier(raw, pos);

            default:
                throw 'Cannot parse value "${TokenHelper.tokenToString(token)}" ${TokenHelper.extractPos(token)}';
        }
    }

    function parseObject(): Any {
        var firstToken: Token = tokens[currToken++];
        var currentToken: Token = null;
        var nextIsComma: Bool = false;
        var output: Any = {};

        while (true) {
            currentToken = tokens[currToken];

            if (currentToken == null)
                throw 'Object must be closed with a right brace ${TokenHelper.extractPos(firstToken)}';

            switch (currentToken) {
                case TRBrace(_):
                    // end of object
                    currToken++;
                    break;

                case TComma(_) if (nextIsComma):
                    // trailing comma/separator comma
                    currToken++;
                    nextIsComma = false;

                case ((!nextIsComma && (_.match(TString(_)) || _.match(TId(_)))) => true):
                    parseKeyValuePair(output);
                    nextIsComma = true;

                default:
                    throw 'Unexpected "${TokenHelper.tokenToString(currentToken)}" ${TokenHelper.extractPos(currentToken)}';
            }
        }

        return output;
    }

    function parseArray(): Array<Any> {
        var firstToken: Token = tokens[currToken++];
        var currentToken: Token = null;
        var nextIsComma: Bool = false;
        var output: Array<Any> = [];

        while (true) {
            currentToken = tokens[currToken];

            if (currentToken == null)
                throw 'Array must be closed with a right bracket ${TokenHelper.extractPos(firstToken)}';

            switch (currentToken) {
                case TRBracket(_):
                    // end of array
                    currToken++;
                    break;

                case TComma(_) if (nextIsComma):
                    currToken++;
                    nextIsComma = false;

                case (!nextIsComma => true):
                    output.push(parseValue());
                    nextIsComma = true;

                default:
                    throw 'Unexpected "${TokenHelper.tokenToString(currentToken)}" ${TokenHelper.extractPos(currentToken)}';
            }
        }

        return output;
    }

    function parseKeyValuePair(object: Any): Void {
        var keyToken: Token = tokens[currToken];
        var key: String = switch (keyToken) {
            case TString(key, _), TId(key, _):
                key;
            default:
                throw 'This shouldn\'t be reachable.';
        };

        if (!nextTokenIsColon())
            throw 'Expected colon next to key "${key}" ${TokenHelper.extractPos(keyToken)}';

        if (Reflect.hasField(object, key))
            throw 'Duplicate key "${key}" ${TokenHelper.extractPos(keyToken)}';

        currToken++;

        var value: Any = parseValue();
        Reflect.setProperty(object, key, value);
    }

    function parseIdentifier(raw: String, pos: TokenPos): Any {
        switch (raw) {
            case 'null':
                return null;

            case 'true':
                return true;

            case 'false':
                return false;

            case 'Infinity', '+Infinity':
                return Math.POSITIVE_INFINITY;

            case '-Infinity':
                return Math.NEGATIVE_INFINITY;

            case 'NaN', '+NaN', '-NaN':
                return Math.NaN;

            case (hexadecimalRegex.match(_) => true):
                return Std.parseInt(raw);

            case (numberRegex.match(_) => true):
                return Std.parseFloat(raw);

            default:
                throw 'Couldn\'t parse value "${raw}" ${pos}';
        }
    }

    function nextTokenIsColon(): Bool {
        var token: Token = tokens[++currToken];
        return token != null && token.match(TColon(_));
    }

    function invalidEof(): Void {
        var token: Token = tokens[currToken];
        var pos: TokenPos = TokenHelper.extractPos(token);

        var char: String = TokenHelper.tokenToString(token);
        if (char.length > 1)
            char = char.charAt(0);

        throw 'Invalid non-whitespace character after value: "${char}" ' + pos;
    }
}
