package haxe.json5;

import haxe.json5.StringifyOptions;

/** Converts Haxe values to JSON5. The public API delegates to this class. */
class Stringifier {
	var quote: String;
	var quoteKeys: Bool;
	var indent: String;
	var explicitPlusSign: Bool;
	var hexadecimal: Bool;
	var trailingComma: Bool;

	public function new(?options: StringifyOptions) {
		quote = options != null && options.singleQuotes == false ? '"' : "'";
		quoteKeys = options != null && options.quoteKeys == true;
		indent = options != null && options.indent != null ? options.indent : '';
		explicitPlusSign = options != null && options.explicitPlusSign == true;
		hexadecimal = options != null && options.hexadecimal == true;
		trailingComma = options != null && options.trailingComma == true;
	}

	public function stringify(value: Any): String
		return stringifyValue(value, 0);

	function stringifyValue(value: Any, depth: Int): String {
		if (value == null)
			return 'null';
		if (Std.isOfType(value, String))
			return quoteString(cast value);
		if (Std.isOfType(value, Bool))
			return value ? 'true' : 'false';
		if (Std.isOfType(value, Int) || Std.isOfType(value, Float))
			return stringifyNumber(cast value);
		if (Std.isOfType(value, Array))
			return stringifyArray(cast value, depth);

		var fields = Reflect.fields(value);
		if (fields != null)
			return stringifyObject(value, fields, depth);
		throw 'Unsupported Haxe value in JSON5 stringify';
	}

	function stringifyNumber(value:Float):String {
		if (Math.isNaN(value))
			return 'NaN';
		if (value == Math.POSITIVE_INFINITY)
			return 'Infinity';
		if (value == Math.NEGATIVE_INFINITY)
			return '-Infinity';
		var representation = hexadecimal && value == Math.ffloor(value) ? formatHexadecimal(value) : Std.string(value);
		if (explicitPlusSign && value > 0)
			representation = '+' + representation;
		return representation;
	}

	function formatHexadecimal(value:Float):String {
		// StringTools.hex accepts Int, so retain decimal notation outside its range.
		if (value < -2147483648.0 || value > 2147483647.0)
			return Std.string(value);
		var sign = value < 0 ? '-' : '';
		return sign + '0x' + StringTools.hex(Std.int(Math.abs(value))).toLowerCase();
	}

	function stringifyArray(values:Array<Dynamic>, depth:Int):String {
		if (values.length == 0)
			return '[]';
		var parts = [for (value in values) linePrefix(depth + 1) + stringifyValue(value, depth + 1)];
		var suffix = trailingComma ? ',' : '';
		return '[\n' + parts.join(',\n') + suffix + '\n' + linePrefix(depth) + ']';
	}

	function stringifyObject(value:Dynamic, fields:Array<String>, depth:Int):String {
		if (fields.length == 0)
			return '{}';
		var parts = [];
		for (field in fields) {
			var key = !quoteKeys && isIdentifier(field) ? field : quoteString(field);
			parts.push(linePrefix(depth + 1) + key + ': ' + stringifyValue(Reflect.field(value, field), depth + 1));
		}
		var suffix = trailingComma ? ',' : '';
		return '{\n' + parts.join(',\n') + suffix + '\n' + linePrefix(depth) + '}';
	}

	function linePrefix(depth:Int):String
		return repeat(indent, depth);

	function repeat(value:String, count:Int):String {
		var result = new StringBuf();
		for (i in 0...count)
			result.add(value);
		return result.toString();
	}

	function isIdentifier(value:String):Bool
		return ~/^[A-Za-z_$][A-Za-z0-9_$]*$/.match(value);

	function quoteString(value:String):String {
		var out = new StringBuf();
		out.add(quote);
		for (i in 0...value.length) {
			var c = value.charAt(i);
			switch (c) {
				case '\\':
					out.add('\\\\');
				case '\n':
					out.add('\\n');
				case '\r':
					out.add('\\r');
				case '\t':
					out.add('\\t');
				case '\u0008':
					out.add('\\b');
				case '\u000C':
					out.add('\\f');
				default:
					if (c == quote)
						out.add('\\' + c)
					else
						out.add(c);
			}
		}
		out.add(quote);
		return out.toString();
	}
}
