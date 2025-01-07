import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/signers';
import { assert, expect } from "chai";
import { network, deployments, ethers } from "hardhat";
import { developmentChains, networkConfig } from "../../deploy/configs/upgradeableNFTConfig";
import { UpgradeableNFT } from '../../typechain-types';

!developmentChains.includes(network.name)
    ? describe.skip
    : describe("UpgradeableNFT Contract Unit Tests", function () {
        console.log("");
        console.log(`Detected network: ${network.name}, starting unit tests...`);

        let upgradeableNFTContract: UpgradeableNFT;
        let owner: SignerWithAddress;
        let user: SignerWithAddress;
        let accounts: SignerWithAddress[];
        let chainId: number;
        let snapshotId: string;

        beforeEach(async () => {
            snapshotId = await network.provider.send("evm_snapshot", []);

            accounts = await ethers.getSigners();
            owner = accounts[0];
            user = accounts[1];
            chainId = network.config.chainId!;

            await deployments.fixture(["UpgradeableNFT"]);
            const deployment = await deployments.get("UpgradeableNFT");
            upgradeableNFTContract = await ethers.getContractAt("UpgradeableNFT", deployment.address, owner);
        });

        afterEach(async function () {
            await network.provider.send("evm_revert", [snapshotId]);
        });

        describe("Check initial contract states", () => {
            it("Initialized with the correct name and symbol", async () => {
                const name = await upgradeableNFTContract.name();
                const symbol = await upgradeableNFTContract.symbol();
                assert.equal(networkConfig[chainId!].name, name);
                assert.equal(networkConfig[chainId!].symbol, symbol);
            });

            it("Initialized with the correct owner", async () => {
                const currentOwner = await upgradeableNFTContract.owner();
                assert.equal(currentOwner, owner.address);
            });
        });

        describe("Check mint", () => {
            it("User can mint less than or equal to 3 tokens at a time", async () => {
                const tokenBalanceBefore = await upgradeableNFTContract.balanceOf(user.address);
                assert.equal(tokenBalanceBefore.toString(), "0");

                const tokensToMint = 3;

                await upgradeableNFTContract.connect(user).mint(tokensToMint);
                const tokenBalanceAfter = await upgradeableNFTContract.balanceOf(user.address);
                assert.equal(tokenBalanceAfter.toString(), tokensToMint.toString());
            });

            it("User can not mint more than 3 at a time", async () => {
                await expect(upgradeableNFTContract.connect(user).mint(4))
                    .to
                    .be
                    .revertedWithCustomError(upgradeableNFTContract, "QuantityExceeded");
            });
        });
    });