import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-ethers";
import "@nomicfoundation/hardhat-toolbox";
require("dotenv").config();

const config: HardhatUserConfig | any = {
  defaultNetwork: "sepolia",
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 800,
      },
    },
  },
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC || "",
      accounts: process.env.PK !== undefined ? [process.env.PK] : [],
    },
    mainnet: {
      url: process.env.MAINNET_RPC || "",
      accounts: process.env.PK !== undefined ? [process.env.PK] : [],
    },
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY,
  },
  sourcify: {
    // Disabled by default
    // Doesn't need an API key
    enabled: true,
  },
};

export default config;
