const TestCBOR = artifacts.require("./TestCBOR.sol");
const cbor = require("cbor");
//const Buffer = require('buffer/').Buffer;

contract('CBOR', function(accounts) {
  it('should return valid CBOR-encoded data', async function() {
    var test = await TestCBOR.new();
    var result = new Buffer((await test.getTestData()).slice(2), "hex");
    var decoded = await cbor.decodeFirst(result);
    assert.deepEqual(decoded, {
      "key1": "value1",
      "long": "This string is longer than 24 characters.",
      "array": [0, 23, 24, 0x100, 0x10000, 0x100000000, -42]
    });
  });
});
