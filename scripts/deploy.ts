import { ethers } from "hardhat";

async function main() {
  const network = await ethers.provider.getNetwork();
  console.log(
    `Deploying to network: ${network.name} (chainId: ${network.chainId})`
  );

  const [deployer] = await ethers.getSigners();
  console.log(`Deploying contracts with the account: ${deployer.address}`);

  const initialBalance = await ethers.provider.getBalance(deployer.address);
  console.log(`Account balance: ${ethers.formatEther(initialBalance)} ETH`);

  const ExampleReserveToken = await ethers.getContractFactory(
    "ExampleReserveToken"
  );
  const exampleERC20 = await ExampleReserveToken.deploy();
  await exampleERC20.waitForDeployment();

  const ERC721NTest = await ethers.getContractFactory("ERC721NTest");
  const erc721n = await ERC721NTest.deploy(await exampleERC20.getAddress());
  await erc721n.waitForDeployment();

  console.log("ERC721NTest deployed to:", await erc721n.getAddress());
  console.log(
    "ExampleReserveToken deployed to:",
    await exampleERC20.getAddress()
  );

  const finalBalance = await ethers.provider.getBalance(deployer.address);
  console.log(
    `Deployment cost: ${ethers.formatEther(initialBalance - finalBalance)} ETH`
  );

  console.log("Deployment and verification completed successfully");
}

main().catch((error) => {
  console.error("Deployment failed:", error);
  process.exitCode = 1;
});
