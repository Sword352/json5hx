package haxe;

import haxe.json5.Lexer;
import haxe.json5.Parser;
import haxe.json5.Stringifier;
import haxe.json5.StringifyOptions;

class Json5 {
    /**
     * Parses a JSON5 document into an Haxe object.
     * An error is thrown if the document isn't syntactically correct.
     * @param content Document to parse.
     * @return Any
     */
    public static function parse(content: String): Null<Any> {
        if (content == null)
            throw 'Cannot parse null Json5 document';

        if (content.length == 0)
            return null;

        var lexer: Lexer = new Lexer(content);
        var parser: Parser = new Parser(lexer.tokenize());
        return parser.parse();
    }

    /**
     * Converts a non-null Haxe object to a JSON5 document.
     * @param value The value or object to stringify.
     * @param options Optional parameters to format the final output.
     * @return String
     */
    public static function stringify(value: Any, ?options: StringifyOptions): String {
        if (value == null)
            throw 'Cannot stringify null Json5 value';
        return new Stringifier(options).stringify(value);
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
