pragma solidity ^0.4.19;

import "../contracts//Buffer.sol";
import "../contracts/CBOR.sol";

contract TestCBOR {
    using CBOR for Buffer.buffer;

    function getTestData() public pure returns(bytes) {
        Buffer.buffer memory buf;
        Buffer.init(buf, 64);

        // Maps
        buf.startMap();
        // Short strings
        buf.encodeString("key1");
        buf.encodeString("value1");

        // Longer strings
        buf.encodeString("long");
        buf.encodeString("This string is longer than 24 characters.");

        // Arrays
        buf.encodeString("array");
        buf.startArray();
        buf.encodeInt(0);
        buf.encodeInt(23);
        buf.encodeInt(24);

        // 2, 4, and 8 byte numbers.
        buf.encodeInt(0x100);
        buf.encodeInt(0x10000);
        buf.encodeInt(0x100000000);

        // Negative numbers
        buf.encodeInt(-42);

        buf.endSequence();
        buf.endSequence();

        return buf.buf;
    }
}
