// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/Counters.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";


contract WrappedERC1155 is ERC721, ERC1155Holder, Ownable, ReentrancyGuard {
    uint256 private _nextTokenId = 0;

    struct WrappedInfo {
        address originalContract;
        uint256 id1155;
        uint256 amount;
    }

    mapping(uint256 => WrappedInfo) public wrappedTokens;

    constructor(address initialOwner)
        ERC721("Wrapped1155", "W1155")
        Ownable(initialOwner) // ✅ pass owner explicitly
    {}

    // Explicitly override supportsInterface to resolve conflict
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC1155Holder)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

  

    function wrap(
        address _buyer,
        address erc1155,
        uint256 id,
        uint256 amount
    ) external  returns (uint256) {
        IERC1155 token = IERC1155(erc1155);

        // uint256 userBalance = token.balanceOf(msg.sender, id);
        // require(userBalance >= amount, "Insufficient ERC1155 balance");

        bool isApproved = token.isApprovedForAll(msg.sender, address(this));
        require(isApproved, "WrappedERC1155 not approved to transfer tokens");

        token.safeTransferFrom(msg.sender, address(this), id, amount, "");

        uint256 newId = _nextTokenId;
        _nextTokenId += 1;
        _mint(_buyer, newId);

        wrappedTokens[newId] = WrappedInfo({
            originalContract: erc1155,
            id1155: id,
            amount: amount
        });

        return newId;
    }

    function unwrap(uint256 tokenId) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        WrappedInfo memory info = wrappedTokens[tokenId];

        _burn(tokenId);
        IERC1155(info.originalContract).safeTransferFrom(
            address(this),
            msg.sender,
            info.id1155,
            info.amount,
            ""
        );
        delete wrappedTokens[tokenId];
    }

    function mint(
        address to,
        uint256 id
    ) public {
        _mint(to, id);
    }

    function tokenInfo(uint256 tokenId)
        external
        view
        returns (WrappedInfo memory)
    {
        return wrappedTokens[tokenId];
    }
}

// Inheritance :
// ERC721: Allows wrapping each ERC1155 deposit into a unique NFT.
// ERC1155Holder: So the contract can receive and hold ERC1155 tokens.
// Ownable: Ownership control (constructor fixed with initialOwner).
// ReentrancyGuard: Protection against reentrancy attacks.
