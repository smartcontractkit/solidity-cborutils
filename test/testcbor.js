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
    var result = await test.getTestDataBig();

    // js CBOR library doesn't support negative bignum encodings as described in the RFC, so we have to verify the raw codes
    assert.equal(result, '0x' +
      'bf' + // map(*)
      '67' + // text(7)
      '6269676e756d73' + // "bignums"
      '9f' + // array(*)
      'c2' + // tag(2) == unsigned bignum
      '49' + // bytes(9)
      '010000000000000000' + // int(18446744073709551616)
      'c2' + // tag(2) == unsigned bignum
      '5820' + // bytes(32)
      '4000000000000000000000000000000000000000000000000000000000000000' + // int(28948022309329048855892746252171976963317496166410141009864396001978282409984)
      'c3' + // tag(3) == signed bignum
      '48' + // bytes(8)
      'ffffffffffffffff' + // int(18446744073709551615)
      'c3' + // tag(3) == signed bignum
      '5820' + // bytes(32)
      '3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' // int(28948022309329048855892746252171976963317496166410141009864396001978282409983)
    );
  });
});
