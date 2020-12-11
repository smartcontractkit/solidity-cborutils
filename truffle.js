var ganache = require('ganache-cli');

module.exports = {
  network: 'test',
  networks: {
    development: {
      host: '127.0.0.1',
      port: 18545,
      network_id: '*' // Match any network id
    },
    ganache_cli: {
      provider: ganache.provider(),
      network_id: '*'
    }
  },
  compilers: {
    solc: {
      version: "0.6.12"
    }
  }
};
