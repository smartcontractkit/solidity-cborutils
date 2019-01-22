# solidity-cborutils [![CircleCI](https://circleci.com/gh/smartcontractkit/solidity-cborutils.svg?style=shield)](https://circleci.com/gh/smartcontractkit/solidity-cborutils)
Utilities for encoding [CBOR](http://cbor.io/) data in solidity

## Install

```bash
$ git clone https://github.com/smartcontractkit/solidity-cborutils.git
$ cd solidity-cborutils
$ npm install
```
## Usage

The Buffer library is not intended to be moved to storage.
In order to persist a Buffer in storage from memory,
   you must manually copy each of its attributes to storage,
   and back out when moving it back to memory.

## Test

```bash
$ truffle test
```