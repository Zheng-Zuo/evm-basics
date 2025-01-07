export interface networkConfigItem {
    networkName?: string;
    name: string;
    symbol: string;
}

export interface networkConfigInfo {
    [key: number]: networkConfigItem;
}

export const networkConfig: networkConfigInfo = {
    31337: {
        networkName: "localhost",
        name: "Upgradeable NFT",
        symbol: "UNFT",
    },

    11155111: {
        networkName: "sepolia",
        name: "Upgradeable NFT",
        symbol: "UNFT",
    },

    421614: {
        networkName: "arbitrumSepolia",
        name: "Upgradeable NFT",
        symbol: "UNFT",
    },

    2494104990: {
        networkName: "shasta",
        name: "Upgradeable NFT",
        symbol: "UNFT",
    }
};

export const developmentChains = ["hardhat", "localhost"];
export const VERIFICATION_BLOCK_CONFIRMATIONS = 1;