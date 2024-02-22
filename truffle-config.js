require('babel-register');
require('babel-polyfill')

module.exports = {

    networks: {
      development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
      },
    },
  
    contracts_directory: './src/contracts/',
    contracts_build_directory: './src/truffle_abis',
  
    compilers: {
      solc: {
        version:'^0.5.0',
        optimizer:{
          enabled: true,
          runs: 200
        },
      }
    }
  
  };