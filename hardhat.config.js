require("@nomicfoundation/hardhat-toolbox");
// require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config()

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "rinkeby",
  etherscan: {
    apiKey: process.env.API_KEY,
  },
  networks: {
    hardhat: {
      gasMultiplier: 2
    },
    rinkeby: {
      url: process.env.URL_ETH_RINKEBY,
      accounts: [process.env.PRIVATE_KEY]
    },
  },
};
