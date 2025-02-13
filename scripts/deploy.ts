import { ethers } from "hardhat";

async function main() {

  const MyContract = await ethers.getContractFactory("MyContract");

 
  const myContract = await MyContract.deploy(1);


  console.log("Contract deployed to:", myContract.target);
}

// Handle errors properly
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
