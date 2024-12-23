// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {AirdropToken} from "src/AirdropToken.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test {
    MerkleAirdrop private _merkleAirdrop;
    AirdropToken private _airdropToken;

    address private _gasPayer = makeAddr("gasPayer");
    address private _user;
    uint256 private _userPrivateKey;

    bytes32 private constant MERKLE_ROOT = 0xd6da2f7add42ec0f1990dc24f8b43b0c38bae804a92e876ef2c66335f336951d;
    uint256 private constant AMOUNT_TO_CLAIM = 25 * 1e18;

    bytes32 private constant proof1 = 0x7f7b8cc8fa34fceea98e5f3bb1dfa176e82e970c45503ae013b008ff5953a25b;
    bytes32 private constant proof2 = 0x5a8f641306d2df139be19e93fc9d906727262db6c9d7bebd0f6282c5cdfa0a56;
    bytes32[] proofs = [proof1, proof2];

    function setUp() public {
        _userPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; // anvil key #0
        _user = vm.addr(_userPrivateKey);

        DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        (_merkleAirdrop, _airdropToken) = deployer.deployMerkleAirdrop();
    }

    function test_userCanClaim() public {
        uint256 startingBalance = _airdropToken.balanceOf(_user);
        console2.log("User starting token balance: ", startingBalance);

        bytes memory signature = _generateSig(_userPrivateKey, 0, _user, AMOUNT_TO_CLAIM);

        vm.prank(_gasPayer);
        _merkleAirdrop.claim(0, _user, AMOUNT_TO_CLAIM, proofs, signature);

        uint256 endingBalance = _airdropToken.balanceOf(_user);
        console2.log("User ending token balance: ", endingBalance);
    }

    function _generateSig(uint256 privateKey, uint256 index, address account, uint256 amount)
        private
        view
        returns (bytes memory)
    {
        bytes32 digest = _merkleAirdrop.getMessageHash(index, account, amount);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        bytes memory signature = abi.encodePacked(r, s, v);
        return signature;
    }
}
