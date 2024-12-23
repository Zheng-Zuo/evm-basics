// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {MerkleAirdrop, IERC20} from "src/MerkleAirdrop.sol";
import {AirdropToken} from "src/AirdropToken.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 public ROOT = 0xd6da2f7add42ec0f1990dc24f8b43b0c38bae804a92e876ef2c66335f336951d;
    // 4 users, 25 tokens each
    uint256 public constant TOTAL_REWARD = 4 * 25 * 1e18;

    function run() external returns (MerkleAirdrop, AirdropToken) {
        return deployMerkleAirdrop();
    }

    function deployMerkleAirdrop() public returns (MerkleAirdrop, AirdropToken) {
        vm.startBroadcast();

        AirdropToken airdropToken = new AirdropToken("AirdropToken", "AT");
        MerkleAirdrop merkleAirdrop = new MerkleAirdrop("Merkle Airdrop", ROOT, IERC20(airdropToken));
        IERC20(airdropToken).transfer(address(merkleAirdrop), TOTAL_REWARD);

        vm.stopBroadcast();
        return (merkleAirdrop, airdropToken);
    }
}
