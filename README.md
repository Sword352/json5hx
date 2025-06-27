# json5hx

Cross-platform JSON5 parser for Haxe, compliant with the [official specification](https://spec.json5.org/) (with a few minor exceptions).

## Installation
### Via haxelib
`haxelib install json5hx`
### Via git
`haxelib git json5hx https://github.com/Sword352/json5hx`

## Usage
```json5
// myDocument.json5
{
  // comments
  unquoted: 'and you can quote me on that',
  singleQuotes: 'I can use "double quotes" here',
  lineBreaks: "Look, Mom! \
No \\n's!",
  hexadecimal: 0xdecaf,
  leadingDecimalPoint: .8675309, andTrailing: 8675309.,
  positiveSign: +1,
  trailingComma: 'in objects', andIn: ['arrays',],
  "backwardsCompatible": "with JSON",
}
```
```haxe
// Main.hx
package;

import json5hx.Json5;

class Main {
    static function main(): Void {
        var document: String = haxe.Resource.getString("myDocument.json5");
        var object: Any = Json5.parse(document);

        /*
         * {
         *   unquoted : and you can quote me on that,
         *   singleQuotes : I can use "double quotes" here,
         *   lineBreaks : Look, Mom! No \n's!,
         *   hexadecimal : 912559,
         *   leadingDecimalPoint : 0.8675309,
         *   andTrailing : 8675309,
         *   positiveSign : 1,
         *   trailingComma : in objects,
         *   andIn : [arrays],
         *   backwardsCompatible : with JSON
         * }
         */
        trace(object);
    }
}
```

## JSON5 over JSON
As stated in the official specification:
```
The JSON5 Data Interchange Format is a proposed extension to JSON that aims to make it easier for humans to write and maintain by hand.
```
JSON5 offers features JSON doesn't have, notably (but not limited to):
- Unquoted key names
- Single-quoted strings
- Single-line & Multi-line comments
- Trailing commas for structured types (array & object)
- Leading/trailing decimal point for decimal numbers
- Explicit plus sign for decimal numbers
- Hexadecimal numbers
However, it is not meant to be a direct replacement to JSON, despite being backwards compatible with it.
It is recommended to keep JSON for machine-to-machine communication or large data structures, as JSON5 parsing can be much slower in these contexts.
