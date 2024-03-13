import { ethers } from "hardhat";

async function main() {
  const ERC20Address = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // USDC on Sepolia

  const exampleERC20 = await ethers.deployContract("ExampleReserveToken");

  await exampleERC20.waitForDeployment();

  const erc721n = await ethers.deployContract("ERC721NTest", [
    exampleERC20.getAddress(),
  ]);
  await erc721n.waitForDeployment();

  console.log("ERC721NTest deployed to:", await erc721n.getAddress());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
