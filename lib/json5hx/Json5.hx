package json5hx;

class Json5 {
    /**
     * Parses a JSON5 document into an Haxe object.
     * An error is thrown if the document isn't syntactically correct.
     * @param content Document to parse.
     * @return Any
     */
    public static function parse(content: String): Any {
        if (content == null)
            throw 'Cannot parse null Json5 document';

        if (content.length == 0)
            return null;

        var lexer: Lexer = new Lexer(content);
        var parser: Parser = new Parser(lexer.tokenize());
        return parser.parse();
    }

    /**
     * Used by the library to handle warnings.
     * This method can be rebound to a custom function.
     * If it is bound to null, the result is unspecified.
     * @param message The warning message.
     */
    public static dynamic function warning(message: String): Void {
        haxe.Log.trace('\033[43m[json5hx] Warning: ' + message + '\033[0m', null);
    }
}
