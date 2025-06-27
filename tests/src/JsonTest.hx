import json5hx.Json5;
import massive.munit.Assert;

class JsonTest {
    public function new(): Void {}

    @Test
    public function test(): Void {
        var documentString: String = haxe.Resource.getString("res/testDocument.json5");
        var parsedDocument: Any = Json5.parse(documentString);
        
        trace(parsedDocument);

        Assert.areEqual({
            unquoted: 'and you can quote me on that',
            singleQuotes: 'I can use "double quotes" here',
            lineBreaks: "Look, Mom! No \\n's!",
            hexadecimal: 0xdecaf,
            leadingDecimalPoint: .8675309, andTrailing: 8675309.,
            positiveSign: 1,
            trailingComma: 'in objects', andIn: ['arrays'],
            backwardsCompatible: "with JSON",
        }, parsedDocument);
    }
}
