import { ethers } from "hardhat";

async function main() {

  const MyContract = await ethers.getContractFactory("MemeCoin");
  const myContract = await MyContract.deploy();
  console.log("Contract deployed to:", myContract.target);


  const MyContract2 = await ethers.getContractFactory("Marketplace");
  const myContract2 = await MyContract2.deploy();
  console.log("Contract deployed to:", myContract2.target);

}

// Handle errors properly
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
