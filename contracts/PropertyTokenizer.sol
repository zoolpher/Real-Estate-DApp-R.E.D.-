// SPDX-License-Identifier: MIT

pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MyERC1155.sol";

import "hardhat/console.sol";

contract PropertyTokenizer is Ownable {
    MyERC1155 public erc1155Contract;

    uint256 public nextTokenId;
    uint256[] public allTokenIds;

    struct Property {
        string docHash; // IPFS hash
        uint256 amount; // property value
        uint256 tokenId; // unique token ID
        address owner; // property owner
    }
    
    mapping(uint256 => Property) public properties;

    constructor(address _erc1155Address) Ownable(msg.sender) {
        erc1155Contract = MyERC1155(_erc1155Address);
    }

    // Add property and mint ERC1155 automatically
    function addProperty(string memory _docHash, uint256 _amount) external {
        console.log(_docHash, _amount);
        require(bytes(_docHash).length > 0, "Document hash required");   //added 8: 58, 29  
        require(_amount > 0, "---Invalid amount---");

        // event Minted(address indexed to, uint256 indexed tokenId, uint256 amount);

        uint256 tokenId = nextTokenId++;

        properties[tokenId] = Property({
            docHash: _docHash,
            amount: _amount,
            tokenId: tokenId,
            owner: msg.sender
        });

        // Mint ERC1155 tokens using MyERC1155
        
        erc1155Contract.mint(msg.sender, tokenId, _amount);
        
        // try erc1155Contract.mint(msg.sender, tokenId, _amount, "") {      // added 9:1 29
        //     emit Minted(msg.sender, tokenId, _amount);
        // } catch {
        //     revert("---ERC1155 mint failed---");
        // }

        allTokenIds.push(tokenId);

        console.log("these are prop",properties[tokenId].amount);
    }

    function viewProperty(
        uint256 _tokenId
    ) external view returns (Property memory) {
        return properties[_tokenId];
    }

    function viewMyProperties(
        address _user
    ) external view returns (Property[] memory) {
        uint256 count = nextTokenId;
        uint256 owned = 0;

        for (uint256 i = 0; i < count; i++) {
            if (properties[i].owner == _user) owned++;
        }

        Property[] memory result = new Property[](owned);
        uint256 index = 0;
        for (uint256 i = 0; i < count; i++) {
            if (properties[i].owner == _user) {
                result[index] = properties[i];
                index++;
            }
        }

        return result;
    }
}
