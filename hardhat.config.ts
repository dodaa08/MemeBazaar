import dotenv from "dotenv";
dotenv.config();
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/MM4Ea2T15gm-OhvQNLjrNI8cqYoV_Wcr",
      accounts: ["4a5f781e4149ac33a91dec4f361e304fe8fc31251b482d9f232abfef4d33caac"],
    },
  },  
};

export default config;
