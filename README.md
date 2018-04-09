# solidity-cborutils
Utilities for encoding [CBOR](http://cbor.io/) data in solidity

## Install

```bash
$ git clone https://github.com/smartcontractkit/solidity-cborutils.git
$ cd solidity-cborutils
$ yarn install
```

## Test

```bash
$ truffle test
```

## Configure and Deploy for Chainlink Development

Add the following network to `truffle.js` to use [DevNet](https://github.com/smartcontractkit/devnet):
```javascript
module.exports = {
  networks: {
    devnet: {
      host: "127.0.0.1",
      port: 18545,
      network_id: "*",
      gas: 4700000
    }
  }
};
```

Save, then run the following to deploy:

```bash
$ truffle migrate --reset --network devnet
```