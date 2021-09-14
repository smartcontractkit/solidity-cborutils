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

  it('returns > 8 byte int as bytes', async function() {
    var test = await TestCBOR.new();
    var result = await test.getTestDataBigInt();

    // js CBOR library doesn't support negative bignum encodings as described
    // in the RFC, so we have to verify the raw codes
    assert.equal(result, '0x' +
      'bf' +              // map(*)
      '67' +              // text(7)
      '6269676e756d73' +  // "bignums"
      '9f' +              // array(*)
      'c2' +              // tag(2) == unsigned bignum
      '5820' +            // bytes(32)
      '0000000000000000000000000000000000000000000000010000000000000000' +
                          // int(18446744073709551616)
      'c2' +              // tag(2) == unsigned bignum
      '5820' +            // bytes(32)
      '4000000000000000000000000000000000000000000000000000000000000000' +
                          // int(28948022309329048855892746252171976963317496166410141009864396001978282409984)
      'c3' +              // tag(3) == signed bignum
      '5820' +            // bytes(32)
      '0000000000000000000000000000000000000000000000010000000000000000' +
                          // int(18446744073709551616)
      'c3' +              // tag(3) == signed bignum
      '5820' +            // bytes(32)
      '3fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' +
                          // int(28948022309329048855892746252171976963317496166410141009864396001978282409983)
      'ff' +              // primitive(*)
      'ff'                // primitive(*)
    );
  });

  it('returns > 8 byte uint as bytes', async function() {
    var test = await TestCBOR.new();
    var result = await test.getTestDataBigUint();

    // js CBOR library doesn't support negative bignum encodings as described
    // in the RFC, so we have to verify the raw codes
    // bf
    // 68
    // 756269676e756d739fc2582
    assert.equal(result, '0x' +
      'bf' +                // map(*)
      '68' +                // text(7)
      '756269676e756d73' +  // "ubignums"
      '9f' +                // array(*)
      'c2' +                // tag(2) == unsigned bignum
      '5820' +              // bytes(32)
      '0000000000000000000000000000000000000000000000010000000000000000' +
                            // uint(18446744073709551616)
      'c2' +                // tag(2) == unsigned bignum
      '5820' +              // bytes(32)
      '4000000000000000000000000000000000000000000000000000000000000000' +
                            // uint(28948022309329048855892746252171976963317496166410141009864396001978282409984)
      'c2' +                // tag(2) == unsigned bignum
      '5820' +              // bytes(32)
      'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' +
                            // uint(115792089237316195423570985008687907853269984665640564039457584007913129639935)
      'ff' +                // primitive(*)
      'ff'                  // primitive(*)
    );
  });
});
