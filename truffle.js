module.exports = {
  networks: {
    local: {
      host: "localhost",
      port: 9545,
      network_id: "*",
      gas: 4000000,
    }
  },
  mocha: {
    reporter: 'eth-gas-reporter',
    reporterOptions : {
      currency: 'USD',
      gasPrice: 1
    }
  },
  compilers: {
    solc: {
      version: "0.6.12"
    }
  }
};
