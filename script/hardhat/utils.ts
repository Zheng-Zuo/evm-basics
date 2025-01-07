import { run } from 'hardhat';

export const verify = async (contractAddress: string, args: any[], path?: string) => {
    console.log("Verifying contract: ", contractAddress)
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
            contract: path,
        })
    } catch (e: any) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Contract already verified")
        } else {
            console.log(e)
        }
    }
}