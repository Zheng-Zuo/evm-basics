import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { DeployFunction } from 'hardhat-deploy/types';
import {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
} from './configs/upgradeableNFTConfig';
import { verify } from '../script/hardhat/utils';
import { upgrades } from 'hardhat';
import fs from 'fs';

const contractName = "UpgradeableNFT";

const deployContract: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const { network, deployments, getNamedAccounts } = hre;
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    const waitBlockConfirmations = developmentChains.includes(network.name) ?
        1
        : VERIFICATION_BLOCK_CONFIRMATIONS;

    log("\n------------------------------------------------------------------------\n");

    const upgradeableNFTArgs = [
        networkConfig[chainId!].name,
        networkConfig[chainId!].symbol
    ];

    const upgradeableNFT = await deploy(contractName, {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: waitBlockConfirmations,
        proxy: {
            proxyContract: "OpenZeppelinTransparentProxy",
            execute: {
                init: {
                    methodName: "initialize",
                    args: upgradeableNFTArgs
                }
            },
            // viaAdminContract: {
            //     name: "NFTProxyAdmin",
            //     artifact: "NFTProxyAdmin",
            // },
        }
    });

    const upgradeableNFTAddresses = {
        proxy: upgradeableNFT.address,
        admin: await upgrades.erc1967.getAdminAddress(upgradeableNFT.address),
        implementation: upgradeableNFT.implementation
    };

    log(`\nDeployed upgradeableNFT to ${network.name}...`);
    log("\n------------------------------------------------------------------------\n");

    if (!developmentChains.includes(network.name) && process.env.ETHERSCAN_API_KEY) {
        await verify(upgradeableNFT.address, []);

        const path = `./deploy/deploymentAddresses/${network.name}.json`;
        let data: { [key: string]: string; } = {};
        if (fs.existsSync(path)) {
            let rawdata = fs.readFileSync(path);
            data = JSON.parse(rawdata.toString());
        }

        data["upgradeableNFT"] = upgradeableNFTAddresses as any;
        fs.writeFileSync(path, JSON.stringify(data));
    }
};

export default deployContract;
deployContract.tags = ['all', contractName];