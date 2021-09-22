// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.19 < 0.9.0;

import "@ensdomains/buffer/contracts/Buffer.sol";
import "../contracts/CBOR.sol";

contract TestCBOR {
    using CBOR for Buffer.buffer;

    function getTestData() public pure returns(bytes memory) {
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
        buf.encodeInt(1);
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

    function getTestDataBigInt() public pure returns(bytes memory) {
        Buffer.buffer memory buf;
        Buffer.init(buf, 128);

        buf.startArray();
        buf.encodeInt(type(int256).min);
        buf.encodeInt(type(int256).min+1);
        buf.encodeInt(int256(type(int64).min)-1);
        buf.encodeInt(int256(type(int64).min)+1);
        buf.encodeInt(type(int64).min);
        buf.encodeInt(type(int64).max);
        buf.encodeInt(int256(type(int64).max)+1);
        buf.encodeInt(type(int256).max-1);
        buf.encodeInt(type(int256).max);
        buf.endSequence();

        return buf.buf;
    }

    function getTestDataBigUint() public pure returns(bytes memory) {
        Buffer.buffer memory buf;
        Buffer.init(buf, 128);

        buf.startArray();
        buf.encodeUInt(0);
        buf.encodeUInt(type(uint64).max);
        buf.encodeUInt(uint256(type(uint64).max)+1);
        buf.encodeUInt(type(uint256).max-1);
        buf.encodeUInt(type(uint256).max);
        buf.endSequence();

        return buf.buf;
    }
}
