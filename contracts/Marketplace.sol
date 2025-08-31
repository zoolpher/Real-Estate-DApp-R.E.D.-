// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

import "./WrappedERC1155.sol";

contract Marketplace is ERC1155Holder, Ownable {
    WrappedERC1155 public wrappedNFT;

    struct Listing {
        address seller;
        uint256 tokenId;
        uint256 amount;
        uint256 pricePerToken; // in wei
        bool active;
    }

    IERC1155 public propertyToken;

    uint256 public listingCounter;

    mapping(uint256 => Listing) public listings;
    mapping(uint256 => uint256[]) public listingToNFTs;

    event PropertyListed(
        uint256 listingId,
        address seller,
        uint256 tokenId,
        uint256 amount,
        uint256 pricePerToken
    );
    event PropertySold(
        uint256 listingId,
        address buyer,
        uint256 amount,
        uint256 totalPrice
    );
    event ListingCancelled(uint256 listingId);

    constructor(address _erc1155, address _wrappedNFT) Ownable(msg.sender) {
        propertyToken = IERC1155(_erc1155);
        wrappedNFT = WrappedERC1155(_wrappedNFT);
    }

    function listProperty(
        uint256 tokenId,
        uint256 amount,
        uint256 pricePerToken
    ) external {
        require(amount > 0, "Amount must be > 0");
        require(pricePerToken > 0, "Price must be > 0");

        // Seller must approve marketplace in frontend
        require(
            propertyToken.balanceOf(msg.sender, tokenId) >= amount,
            "Not enough tokens"
        );

        listingCounter++;
        listings[listingCounter] = Listing(
            msg.sender,
            tokenId,
            amount,
            pricePerToken,
            true
        );
        // listingCounter++;

        emit PropertyListed(
            listingCounter,
            msg.sender,
            tokenId,
            amount,
            pricePerToken
        );
    }

    // function listingCounter() external view returns(uint256) {
    //     return listingCounter;
    // }

    function buyProperty(uint256 listingId, uint256 amount) external payable {
        Listing storage lst = listings[listingId];

        console.log(lst.amount);

        require(lst.active, "Listing not active");
        require(amount > 0 && amount <= lst.amount, "Invalid amount");

        // 🔎 Check seller's balance in ERC1155
        uint256 sellerBalance = propertyToken.balanceOf(
            lst.seller,
            lst.tokenId
        );

        require(sellerBalance >= amount, "Seller doesn't have enough tokens");

        uint256 totalPrice = amount * lst.pricePerToken;
        //--------------------------------------------------------
        require(msg.value >= totalPrice, "Insufficient payment");

        // Transfer ERC1155 tokens from seller to Marketplace for wrapping
        propertyToken.safeTransferFrom(
            lst.seller,
            address(wrappedNFT),
            lst.tokenId,
            amount,
            ""
        );
        uint256 newNFTId = wrappedNFT.wrap(
            msg.sender,
            address(propertyToken),
            lst.tokenId,
            amount
        );

        // Transfer ERC1155 token
        // propertyToken.safeTransferFrom(
        //     lst.seller,
        //     msg.sender,
        //     lst.tokenId,
        //     amount,
        //     ""
        // );

        listingToNFTs[listingId].push(newNFTId);

        // Pay seller
        payable(lst.seller).transfer(totalPrice);

        // Update listing
        lst.amount -= amount;
        if (lst.amount == 0) {
            lst.active = false;
        }

        emit PropertySold(listingId, msg.sender, amount, totalPrice);
    }

    function cancelListing(uint256 listingId) external {
        Listing storage lst = listings[listingId];
        require(lst.seller == msg.sender, "Not seller");
        lst.active = false;
        emit ListingCancelled(listingId);
    }
}

// pragma solidity ^0.8.20;

// import "./Listing.sol";
// import "./WrappedERC1155.sol";
// import "./Payout.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

// /*

//     # 5th contract to be executed

//     This contract provides market place for the NFT Buyers

//     It provides following functions :
//     - buy() function
//         - markSold()
//         - safeTransferFrom()
//         - distributeETH()

//     What to do after deployment:
//     - Copy the deployed address.
//     - This is the main contract buyers will interact with.

// */

// contract Marketplace is ReentrancyGuard {

//     Listing public listingContract;
//     Payout public payoutContract;

//     constructor(address _listing, address _payout) {
//         listingContract = Listing(_listing);
//         payoutContract = Payout(_payout);
//     }

//     function buy(uint256 listingId) external payable nonReentrant {
//         (
//             ,// uint256 id,
//             address seller,
//             address assetContract,
//             uint256 tokenId,
//             uint256 price,
//             Listing.Status status
//         ) = listingContract.listings(listingId);

//         require(status == Listing.Status.Active, "---Listing is inactive---");
//         require(msg.value >= price, "---Insufficient balance---");
//         require(msg.sender != seller, "---Seller cannot buy own NFT---");

//         // Mark sold in Listing contract
//         listingContract.markSold(listingId);

//         // Transfer wrapped token to buyer
//         IERC721(assetContract).safeTransferFrom(
//             address(listingContract),
//             msg.sender,
//             tokenId
//         );

//         // Forward funds to payout contract
//         payoutContract.distributeETH{value: msg.value}();
//     }
// }
