// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyERC1155 is ERC1155, Ownable {
    // uint256 public currentTokenId = 0;

    // Pass a URI to the base ERC1155 constructor
    constructor(string memory uri) ERC1155(uri) Ownable(msg.sender) {}

    function mint(
        address to,
        uint256 tokenId,
        uint256 amount
    ) external onlyOwner returns (uint256) {
        // uint256 tokenId = currentTokenId;
        _mint(to, tokenId, amount, "");
        // currentTokenId += 1;
        return tokenId;
    }
}
