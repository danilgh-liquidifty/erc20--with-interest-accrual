const {expect} = require("chai");
const {loadFixture} = require("@nomicfoundation/hardhat-network-helpers");

describe("N11 contract", function () {
  async function deployTokenFixture() {
    const N11 = await ethers.getContractFactory("N11");
    const [owner, addr1] = await ethers.getSigners();

    const hardhatToken = await N11.deploy();
    await hardhatToken.deployed();

    return {N11, hardhatToken, owner, addr1};
  }

  describe("Deployment", function () {
    it("Should assign the total supply of tokens to the owner", async function () {
      const {hardhatToken, owner} = await loadFixture(deployTokenFixture);
      const ownerBalance = await hardhatToken.balanceOf(owner.address);
      expect(await hardhatToken.totalSupply()).to.equal(ownerBalance);
    });
  });

  describe("Transactions", function () {
    it("Should transfer tokens between accounts", async function () {
      const {hardhatToken, owner, addr1} = await loadFixture(deployTokenFixture);
      await expect(hardhatToken.transfer(addr1.address, 50)).to.changeTokenBalances(hardhatToken, [owner, addr1], [-50, 50]);
    });

    it("should emit Transfer events", async function () {
      const {hardhatToken, owner, addr1} = await loadFixture(deployTokenFixture);
      await expect(hardhatToken.transfer(addr1.address, 50))
        .to.emit(hardhatToken, "Transfer")
        .withArgs(owner.address, addr1.address, 50);
    });

    it("Should fail if sender doesn't have enough tokens", async function () {
      const {hardhatToken, owner, addr1} = await loadFixture(deployTokenFixture);
      const initialOwnerBalance = await hardhatToken.balanceOf(owner.address);
      await expect(hardhatToken.connect(addr1).transfer(owner.address, 100)).to.be.revertedWith("N11: transfer amount exceeds balance");
      expect(await hardhatToken.balanceOf(owner.address)).to.equal(initialOwnerBalance);
    });
  });
});
