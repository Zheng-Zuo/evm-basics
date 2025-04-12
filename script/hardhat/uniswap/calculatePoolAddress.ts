import { defaultAbiCoder } from "@ethersproject/abi";
import { getCreate2Address } from "@ethersproject/address";
import { keccak256 } from "@ethersproject/solidity";
import dotenv from "dotenv";
import yargs from "yargs/yargs";

dotenv.config();

function getOptions() {
    const options = yargs(process.argv.slice(2))
        .option("initCodeHash", {
            type: "string",
            describe: "init code hash",
            default: "0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54",
        })
        .option("factoryAddress", {
            type: "string",
            describe: "factory address",
            default: "0x1F98431c8aD98523631AE4a59f267346ea31F984",
        })
        .option("token0", {
            type: "string",
            describe: "token0 address",
            default: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
        })
        .option("token1", {
            type: "string",
            describe: "token1 address",
            default: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
        })
        .option("fee", {
            type: "number",
            describe: "fee",
            default: 100,
        });

    return options.argv;
}

async function main() {
    let options: any = getOptions();
    const initCodeHash = options.initCodeHash;
    const factoryAddress = options.factoryAddress;
    const token0Addr = options.token0;
    const token1Addr = options.token1;
    const fee = options.fee;

    const salt = keccak256(
        ["bytes"],
        [defaultAbiCoder.encode(["address", "address", "uint24"], [token0Addr, token1Addr, fee])]
    );

    const poolAddress = getCreate2Address(factoryAddress, salt, initCodeHash);

    console.log(poolAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

// ts-node script/hardhat/uniswap/calculatePoolAddress.ts
