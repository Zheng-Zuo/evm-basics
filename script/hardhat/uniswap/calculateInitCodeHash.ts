import { ethers } from "hardhat";
import UniswapV3PoolArtifact from "@uniswap/v3-core/artifacts/contracts/UniswapV3Pool.sol/UniswapV3Pool.json";

async function main() {
    const bytecode = UniswapV3PoolArtifact.bytecode;
    const initCodeHash = ethers.utils.keccak256(bytecode);
    console.log(initCodeHash);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
