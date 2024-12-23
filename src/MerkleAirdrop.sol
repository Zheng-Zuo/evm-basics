// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { BitMaps } from "@openzeppelin/contracts/utils/structs/BitMaps.sol";

contract MerkleAirdrop is EIP712 {
    error InvalidProof();
    error AlreadyClaimed();
    error InvalidSignature();

    event Claimed(uint256 index, address account, uint256 amount);

    using SafeERC20 for IERC20;

    bytes32 private immutable _merkleRoot;
    IERC20 private immutable _airdropToken;
    BitMaps.BitMap private _airdropList;
    string private constant VERSION = "1";
    bytes32 private constant CLAIM_TYPEHASH = keccak256("claim(uint256 index,address account,uint256 amount)");

    constructor(string memory name, bytes32 merkleRoot, IERC20 airdropToken) EIP712(name, VERSION) {
        _merkleRoot = merkleRoot;
        _airdropToken = airdropToken;
    }

    function claim(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        bytes calldata signature
    )
        external
    {
        if (BitMaps.get(_airdropList, index)) {
            revert AlreadyClaimed();
        }
        _verifySignature(index, account, amount, signature);
        _verifyProof(index, account, amount, merkleProof);

        BitMaps.setTo(_airdropList, index, true);
        emit Claimed(index, account, amount);

        _airdropToken.safeTransfer(account, amount);
    }

    /*//////////////////////////////////////////////////////////////
                          INTERNAL AND PRIVATE
    //////////////////////////////////////////////////////////////*/
    function _verifyProof(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    )
        private
        view
    {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(index, account, amount))));

        if (!MerkleProof.verify(merkleProof, _merkleRoot, leaf)) {
            revert InvalidProof();
        }
    }

    function _verifySignature(uint256 index, address account, uint256 amount, bytes calldata signature) private view {
        bytes32 digest = getMessageHash(index, account, amount);
        if (ECDSA.recover(digest, signature) != account) {
            revert InvalidSignature();
        }
    }

    /*//////////////////////////////////////////////////////////////
                    GETTER FUNCTIONS (VIEW AND PURE)
    //////////////////////////////////////////////////////////////*/
    function getMessageHash(uint256 index, address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(keccak256(abi.encode(CLAIM_TYPEHASH, index, account, amount)));
    }

    function getAirdropToken() external view returns (address) {
        return address(_airdropToken);
    }

    function getMerkleRoot() external view returns (bytes32) {
        return _merkleRoot;
    }

    function getClaimedStatus(uint256 index) external view returns (bool) {
        return BitMaps.get(_airdropList, index);
    }
}
