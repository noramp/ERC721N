import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("ERC721N", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployERC721N() {
    const ERC20Address = "0x5FbDB2315678afecb367f032d93F642f64180aa3"; // USDC on Sepolia
    const erc721n = await ethers.deployContract("ERC721NTest", [ERC20Address]);

    await erc721n.waitForDeployment();

    return { erc721n, ERC20Address };
  }

  describe("Deployment", function () {
    it("Should set the right ERC20 token", async function () {
      const { erc721n, ERC20Address } = await loadFixture(deployERC721N);

      const erc20FromContract = await erc721n.getReserveTokenAddress();
      console.log({ erc20FromContract, ERC20Address });
      expect(erc20FromContract).to.equal(ERC20Address);
    });
  });
});
