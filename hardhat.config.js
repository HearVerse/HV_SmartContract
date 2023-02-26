require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.10",
  gasReporter: {
    enabled: true,
    currency: "CHF",
    gasPrice: 21000,
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
};
