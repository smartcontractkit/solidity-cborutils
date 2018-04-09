pragma solidity ^0.4.19;

import "truffle/Assert.sol";
import "../contracts/Buffer.sol";

contract TestBuffer {
    using Buffer for Buffer.buffer;

    function testBufferAppend() public {
      Buffer.buffer memory buf;
      Buffer.init(buf, 256);
      buf.append("Hello");
      buf.append(", ");
      buf.append("world!");
      Assert.equal(string(buf.buf), "Hello, world!", "Unexpected buffer contents.");
    }

    function testBufferAppendByte() public {
      Buffer.buffer memory buf;
      Buffer.init(buf, 256);
      buf.append("Hello,");
      buf.append(0x20);
      buf.append("world!");
      Assert.equal(string(buf.buf), "Hello, world!", "Unexpected buffer contents.");
    }

    function testBufferAppendInt() public {
      Buffer.buffer memory buf;
      Buffer.init(buf, 256);
      buf.append("Hello");
      buf.appendInt(0x2c20, 2);
      buf.append("world!");
      Assert.equal(string(buf.buf), "Hello, world!", "Unexpected buffer contents.");
    }

    function testBufferResizeAppendByte() public {
      Buffer.buffer memory buf;
      Buffer.init(buf, 32);
      buf.append("01234567890123456789012345678901");
      buf.append(0x20);
      Assert.equal(buf.capacity, 64, "Expected buffer capacity to be 64");
      Assert.equal(buf.buf.length, 33, "Expected buffer length to be 33");
      Assert.equal(string(buf.buf), "01234567890123456789012345678901 ", "Unexpected buffer contents");
    }

    function testBufferResizeAppendInt() public {
      Buffer.buffer memory buf;
      Buffer.init(buf, 32);
      buf.append("01234567890123456789012345678901");
      buf.appendInt(0x2020, 2);
      Assert.equal(buf.capacity, 64, "Expected buffer capacity to be 64");
      Assert.equal(buf.buf.length, 34, "Expected buffer length to be 33");
      Assert.equal(string(buf.buf), "01234567890123456789012345678901  ", "Unexpected buffer contents");
    }

    function testBufferResizeAppendBytes() public {
      Buffer.buffer memory buf;
      Buffer.init(buf, 32);
      buf.append("01234567890123456789012345678901");
      buf.append("23");
      Assert.equal(buf.capacity, 64, "Expected buffer capacity to be 64");
      Assert.equal(buf.buf.length, 34, "Expected buffer length to be 33");
      Assert.equal(string(buf.buf), "0123456789012345678901234567890123", "Unexpected buffer contents");
    }

    function testBufferResizeAppendManyBytes() public {
      Buffer.buffer memory buf;
      Buffer.init(buf, 32);
      buf.append("01234567890123456789012345678901");
      buf.append("0123456789012345678901234567890101234567890123456789012345678901");
      Assert.equal(buf.capacity, 128, "Expected buffer capacity to be 64");
      Assert.equal(buf.buf.length, 96, "Expected buffer length to be 33");
      Assert.equal(string(buf.buf), "012345678901234567890123456789010123456789012345678901234567890101234567890123456789012345678901", "Unexpected buffer contents");
    }
}
