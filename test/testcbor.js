const TestCBOR = artifacts.require('./TestCBOR.sol');
const cbor = require('cbor');

contract('CBOR', function(accounts) {
  it('returns valid CBOR-encoded data', async function() {
    var test = await TestCBOR.new();
    var result = new Buffer.from((await test.getTestData()).slice(2), 'hex');
    var decoded = await cbor.decodeFirst(result);
    assert.deepEqual(decoded, {
      'key1': 'value1',
      'long': 'This string is longer than 24 characters.',
      'array': [0, 1, 23, 24, 0x100, 0x10000, 0x100000000, -42]
    });
  });

  it('returns > 8 byte int as bytes', async function() {
    var test = await TestCBOR.new();
    var result = await test.getTestDataBigInt();

    // js CBOR library doesn't support negative bignum encodings as described
    // in the RFC, so we have to verify the raw codes
    assert.equal(result, '0x' +
      '9f' +                                       // array(*)
        'c3' +                                     // tag(3)
          '58' + '20' +                            // bytes(32)
            '7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' +   // "\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
        'c3' +                                     // tag(3)
          '58' + '20' +                            // bytes(32)
            '7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe' +   // "\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFE"
        '3b' + '8000000000000000' +                // negative(9223372036854775808)
        '3b' + '7ffffffffffffffe' +                // negative(9223372036854775806)
        '3b' + '7fffffffffffffff' +                // negative(9223372036854775807)
        '1b' + '7fffffffffffffff' +                // unsigned(9223372036854775807)
        '1b' + '8000000000000000' +                // unsigned(9223372036854775808)
        'c2' +                                     // tag(2)
          '58' + '20' +                            // bytes(32)
            '7ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe' +   // "\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFE"
        'c2' +                                     // tag(2)
          '58' + '20' +                            // bytes(32)
            '7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' +   // "\x7F\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
      'ff'                                         // primitive(*)
    );
  });

  it('returns > 8 byte uint as bytes', async function() {
    var test = await TestCBOR.new();
    var result = await test.getTestDataBigUint();

    // js CBOR library doesn't support negative bignum encodings as described
    // in the RFC, so we have to verify the raw codes
    assert.equal(result, '0x' +
      '9f' +                                       // array(*)
        '00' +                                     // unsigned(0)
        '1b' + 'ffffffffffffffff' +                // unsigned(18446744073709551615)
        'c2' +                                     // tag(2)
          '58' + '20' +                            // bytes(32)
            '0000000000000000000000000000000000000000000000010000000000000000' + // "\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00"
        'c2' +                                     // tag(2)
          '58' + '20' +                            // bytes(32)
            'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe' + // "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFE"
        'c2' +                                     // tag(2)
          '58' + '20' +                            // bytes(32)
            'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff' + // "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF"
      'ff'                                         // primitive(*)
    );
  });
});
