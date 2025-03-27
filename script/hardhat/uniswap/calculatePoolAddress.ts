import { defaultAbiCoder } from "@ethersproject/abi";
import { getCreate2Address } from "@ethersproject/address";
import { keccak256 } from "@ethersproject/solidity";

async function main() {
    const token0Addr = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const token1Addr = "0xdAC17F958D2ee523a2206206994597C13D831ec7";
    const fee = 100;
    const factoryAddress = "0x1F98431c8aD98523631AE4a59f267346ea31F984";
    const salt = keccak256(
        ["bytes"],
        [defaultAbiCoder.encode(["address", "address", "uint24"], [token0Addr, token1Addr, fee])]
    );

    const initCodeHash = "0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54";
    const poolAddress = getCreate2Address(factoryAddress, salt, initCodeHash);

    console.log(poolAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
