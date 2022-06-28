const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Contract", function () {
  it("Should return Contract with Name and Ticker", async function () {
    const Contract = await ethers.getContractFactory("NFTRoyalties2981");
    const contractInstance = await Contract.deploy();
    await contractInstance.deployed();

    expect(await contractInstance.name()).to.equal("NFTRoyalties2981");
    expect(await contractInstance.symbol()).to.equal("EIP2981");
  });

  it("Mint 11 Creator NFT's", async function () {
    const Contract = await ethers.getContractFactory("NFTRoyalties2981");
    const contractInstance = await Contract.deploy();
    await contractInstance.deployed();  

    const mintCreatorNFTsTx = await contractInstance.creatorNFTClaims();
    await mintCreatorNFTsTx.wait();

    const contractOwner = await contractInstance.owner();

    expect(await contractInstance.balanceOf(contractOwner)).to.equal(11);
  })
});
