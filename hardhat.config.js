require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
/** @type import('hardhat/config').HardhatUserConfig */
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});


module.exports = {
  // solidity: "0.7.6",
  solidity: {
    compilers: [
      {
        version: "0.8.6",
      },
      {
        version: "0.7.6",
        settings: {},
      },
    ],
  },
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
    },
    // hardhat: {
    //   forking: {
    //     url: `https://eth-mainnet.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
    //   },
    // },
  },
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
