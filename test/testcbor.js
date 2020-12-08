const TestCBOR = artifacts.require('./TestCBOR.sol');
const cbor = require('cbor');

contract('CBOR', function(accounts) {
  it('returns valid CBOR-encoded data', async function() {
    var test = await TestCBOR.new();
    var result = new Buffer((await test.getTestData()).slice(2), 'hex');
    var decoded = await cbor.decodeFirst(result);
    assert.deepEqual(decoded, {
      'key1': 'value1',
      'long': 'This string is longer than 24 characters.',
      'array': [0, 23, 24, 0x100, 0x10000, 0x100000000, -42]
    });
  });

  it('returns > 8 byte numbers as bytes', async function() {
    var test = await TestCBOR.new();
    var result = new Buffer((await test.getTestDataBig()).slice(2), 'hex');
    var decoded = await cbor.decodeFirst(result);

    assert.deepEqual(decoded, {'bignums': [
      Buffer.from('0100000000000000000', 'hex'),
      Buffer.from('4000000000000000000000000000000000000000000000000000000000000000', 'hex'),
      Buffer.from('ffffffffffffffffffffffffffffffffffffffffffffffff0000000000000000', 'hex'),
      Buffer.from('c000000000000000000000000000000000000000000000000000000000000000', 'hex'),
    ]});
  });
});
