// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@ensdomains/buffer/contracts/Buffer.sol";

library CBOR {
    using Buffer for Buffer.buffer;

    struct CBORBuffer {
        Buffer.buffer buf;
        uint256 depth;
        bool is_fixed_size_sequence[32];
        uint64 remaining_items_in_sequence[32];
    }

    uint8 private constant MAJOR_TYPE_INT = 0;
    uint8 private constant MAJOR_TYPE_NEGATIVE_INT = 1;
    uint8 private constant MAJOR_TYPE_BYTES = 2;
    uint8 private constant MAJOR_TYPE_STRING = 3;
    uint8 private constant MAJOR_TYPE_ARRAY = 4;
    uint8 private constant MAJOR_TYPE_MAP = 5;
    uint8 private constant MAJOR_TYPE_TAG = 6;
    uint8 private constant MAJOR_TYPE_CONTENT_FREE = 7;

    uint8 private constant TAG_TYPE_BIGNUM = 2;
    uint8 private constant TAG_TYPE_NEGATIVE_BIGNUM = 3;

    uint8 private constant CBOR_FALSE = 20;
    uint8 private constant CBOR_TRUE = 21;
    uint8 private constant CBOR_NULL = 22;
    uint8 private constant CBOR_UNDEFINED = 23;

    function create(uint256 capacity) internal pure returns(CBORBuffer memory cbor) {
        Buffer.init(cbor.buf, capacity);
        cbor.depth = 0;
        return cbor;
    }

    function data(CBORBuffer memory buf) internal pure returns(bytes memory) {
        require(buf.depth == 0, "Invalid CBOR");
        return buf.buf.buf;
    }

    function writeUInt256(CBORBuffer memory buf, uint256 value) internal pure {
        decrementRemainingItemsInSequence(buf);
        buf.buf.appendUint8(uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_BIGNUM));
        writeBytesInternal(buf, abi.encode(value));
    }

    function writeInt256(CBORBuffer memory buf, int256 value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeInt256Internal(buf, value);
    }

    function writeUInt64(CBORBuffer memory buf, uint64 value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeUInt64Internal(buf, value);
    }

    function writeInt64(CBORBuffer memory buf, int64 value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeInt64Internal(buf, value);
    }

    function writeBytes(CBORBuffer memory buf, bytes memory value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeBytesInternal(buf, value);
    }

    function writeString(CBORBuffer memory buf, string memory value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, value);
    }

    function writeBool(CBORBuffer memory buf, bool value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeBoolInternal(buf, value);
    }

    function writeNull(CBORBuffer memory buf) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeNullInternal(buf);
    }

    function writeUndefined(CBORBuffer memory buf) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeUndefinedInternal(buf);
    }

    function startArray(CBORBuffer memory buf) internal pure {
        decrementRemainingItemsInSequence(buf);
        markSequenceStart(buf, false, 0);
        startArrayInternal(buf);
    }

    function startFixedArray(CBORBuffer memory buf, uint64 length) internal pure {
        decrementRemainingItemsInSequence(buf);
        markSequenceStart(buf, true, length);
        writeDefiniteLengthType(buf, MAJOR_TYPE_ARRAY, length);
    }

    function startMap(CBORBuffer memory buf) internal pure {
        decrementRemainingItemsInSequence(buf);
        markSequenceStart(buf, false, 0);
        startMapInternal(buf);
    }

    function startFixedMap(CBORBuffer memory buf, uint64 length) internal pure {
        decrementRemainingItemsInSequence(buf);
        markSequenceStart(buf, true, length);
        writeDefiniteLengthType(buf, MAJOR_TYPE_MAP, length);
    }

    function endSequence(CBORBuffer memory buf) internal pure {
        markSequenceEnd(buf);
        writeIndefiniteLengthType(buf, MAJOR_TYPE_CONTENT_FREE);
    }

    function writeKVString(CBORBuffer memory buf, string memory key, string memory value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        writeStringInternal(buf, value);
    }

    function writeKVBytes(CBORBuffer memory buf, string memory key, bytes memory value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        writeBytesInternal(buf, value);
    }

    function writeKVUInt256(CBORBuffer memory buf, string memory key, uint256 value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        writeUInt256Internal(buf, value);
    }

    function writeKVInt256(CBORBuffer memory buf, string memory key, int256 value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        writeInt256Internal(buf, value);
    }

    function writeKVUInt64(CBORBuffer memory buf, string memory key, uint64 value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        writeUInt64Internal(buf, value);
    }

    function writeKVInt64(CBORBuffer memory buf, string memory key, int64 value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        writeInt64Internal(buf, value);
    }

    function writeKVBool(CBORBuffer memory buf, string memory key, bool value) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        writeBoolInternal(buf, value);
    }

    function writeKVNull(CBORBuffer memory buf, string memory key) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        writeNullInternal(buf);
    }

    function writeKVUndefined(CBORBuffer memory buf, string memory key) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        writeUndefinedInternal(buf);
    }

    function writeKVMap(CBORBuffer memory buf, string memory key) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        startMapInternal(buf);
    }

    function writeKVArray(CBORBuffer memory buf, string memory key) internal pure {
        decrementRemainingItemsInSequence(buf);
        writeStringInternal(buf, key);
        startArrayInternal(buf);
    }



    function writeFixedNumeric(
        CBORBuffer memory buf,
        uint8 major,
        uint64 value
    ) private pure {
        if (value <= 23) {
            buf.buf.appendUint8(uint8((major << 5) | value));
        } else if (value <= 0xFF) {
            buf.buf.appendUint8(uint8((major << 5) | 24));
            buf.buf.appendInt(value, 1);
        } else if (value <= 0xFFFF) {
            buf.buf.appendUint8(uint8((major << 5) | 25));
            buf.buf.appendInt(value, 2);
        } else if (value <= 0xFFFFFFFF) {
            buf.buf.appendUint8(uint8((major << 5) | 26));
            buf.buf.appendInt(value, 4);
        } else {
            buf.buf.appendUint8(uint8((major << 5) | 27));
            buf.buf.appendInt(value, 8);
        }
    }

    function writeInt256Internal(CBORBuffer memory buf, int256 value) private pure {
        if (value < 0) {
            buf.buf.appendUint8(
                uint8((MAJOR_TYPE_TAG << 5) | TAG_TYPE_NEGATIVE_BIGNUM)
            );
            writeBytesInternal(buf, abi.encode(uint256(-1 - value)));
        } else {
            writeUInt256Internal(buf, uint256(value));
        }
    }

    function writeBytesInternal(CBORBuffer memory buf, bytes memory value) private pure {
        writeFixedNumeric(buf, MAJOR_TYPE_BYTES, uint64(value.length));
        buf.buf.append(value);
    }

    function writeUInt64Internal(CBORBuffer memory buf, uint64 value) private pure {
        writeFixedNumeric(buf, MAJOR_TYPE_INT, value);
    }

    function writeInt64Internal(CBORBuffer memory buf, int64 value) private pure {
        if(value >= 0) {
            writeFixedNumeric(buf, MAJOR_TYPE_INT, uint64(value));
        } else{
            writeFixedNumeric(buf, MAJOR_TYPE_NEGATIVE_INT, uint64(-1 - value));
        }
    }

    function writeBoolInternal(CBORBuffer memory buf, bool value) private pure {
        writeContentFree(buf, value ? CBOR_TRUE : CBOR_FALSE);
    }

    function writeUndefinedInternal(CBORBuffer memory buf) private pure {
        writeContentFree(buf, CBOR_UNDEFINED);
    }

    function writeNullInternal(CBORBuffer memory buf) private pure {
        writeContentFree(buf, CBOR_NULL);
    }

    function writeStringInternal(CBORBuffer memory buf, string memory key) private pure {
        writeFixedNumeric(buf, MAJOR_TYPE_STRING, uint64(bytes(value).length));
        buf.buf.append(bytes(value));
    }

    function startArrayInternal(CBORBuffer memory buf) private pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_ARRAY);
    }

    function startMapInternal(CBORBuffer memory buf) private pure {
        writeIndefiniteLengthType(buf, MAJOR_TYPE_MAP);
    }

    function writeIndefiniteLengthType(CBORBuffer memory buf, uint8 major)
        private
        pure
    {
        buf.buf.appendUint8(uint8((major << 5) | 31));
    }

    function writeDefiniteLengthType(CBORBuffer memory buf, uint8 major, uint64 length)
        private
        pure
    {
        writeFixedNumeric(buf, major, length);
    }

    function writeContentFree(CBORBuffer memory buf, uint8 value) private pure {
        buf.buf.appendUint8(uint8((MAJOR_TYPE_CONTENT_FREE << 5) | value));
    }

    function decrementRemainingItemsInSequence(CBORBuffer memory buf) private pure {
        if (buf.depth == 0) {
            return;
        }
        uint index = buf.depth - 1;
        if (buf.is_fixed_size_sequence[index] == true) {
            require(buf.remaining_items_in_sequence[index] > 0 "Invalid CBOR");
            if (buf.remaining_items_in_sequence[index] == 1) {
                buf.depth -= 1;
                return
            }
            buf.remaining_items_in_sequence[index] -= 1;
        }
    }

    function markSequenceStart(CBORBuffer memory buf, bool is_fixed_sized, uint64 total_items) private pure {
        require(buf.depth < 32, "Exceeded max nested depth");
        if  (is_fixed_sized) {
            if (total_items == 0) {
                return
            }
            buf.is_fixed_size_sequence[buf.depth] = true;
            buf.remaining_items_in_sequence[buf.depth] = total_items;
        } else {
            buf.is_fixed_size_sequence[buf.depth] = false;
        }
        buf.depth += 1;
    }
    function markSequenceEnd(CBORBuffer memory buf) private pure {
        require(buf.depth > 0, "Invalid CBOR");
        uint index = buf.depth - 1;
        if (buf.is_fixed_size_sequence[index]) {
            require(buf.remaining_items_in_sequence[index] == 0 "Invalid CBOR");
        }
        buf.depth -= 1;
    }
}