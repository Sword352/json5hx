package haxe.json5;

/**
 * Options accepted by Json5.stringify.
 */
typedef StringifyOptions = {
	/** Use single quotes for strings and quoted keys. Defaults to true. */
	@:optional var singleQuotes: Bool;

	/** Quote every object key. Defaults to false for valid identifier keys. */
	@:optional var quoteKeys: Bool;

	/** Indentation string. Empty or omitted produces compact output. */
	@:optional var indent: String;

	/** Prefix positive finite numbers with a plus sign. Defaults to false. */
	@:optional var explicitPlusSign: Bool;

	/** Use hexadecimal notation for finite integral numbers. Defaults to false. */
	@:optional var hexadecimal: Bool;

	/** Append a trailing comma to each non-empty object and array. Defaults to false. */
	@:optional var trailingComma: Bool;
}
