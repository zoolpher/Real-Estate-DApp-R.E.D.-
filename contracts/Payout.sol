// // SPDX-License-Identifier: MIT

// pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


// /*

//     # 4th contract to be executed

//     This contract provides payout for the Investor's

//     It provides following functions :
//     - setSplits(): owner sets the distribution percentages
//     - distributeETH(): splits received ETH among accounts
//     - distributeToken(): splits ERC20 tokens among accounts
   

//    What to do after deployment:
//     - Copy this deployed address.
//     - Will be used in Marketplace.sol to forward funds after NFT purchase.

// */


// contract Payout is Ownable {

//     using SafeERC20 for IERC20;

//     struct Split {
//         address account;
//         uint256 percent; // out of 10000 (basis points)
//     }

//     Split[] public splits;

//     constructor() Ownable(msg.sender) {}

//     function setSplits(Split[] calldata newSplits) external onlyOwner {
//         delete splits;
//         for (uint i = 0; i < newSplits.length; i++) {
//             splits.push(newSplits[i]);
//         }
//     }

//     function distributeETH() external payable {
//         uint256 balance = msg.value;
//         for (uint i = 0; i < splits.length; i++) {
//             uint256 amount = balance * splits[i].percent / 10000;
//             (bool success, ) = splits[i].account.call{value: amount}("");
//             require(success, "ETH transfer failed");
//         }
//     }

//     function distributeToken(address token) external {
//         uint256 balance = IERC20(token).balanceOf(address(this));
//         for (uint i = 0; i < splits.length; i++) {
//             uint256 amount = balance * splits[i].percent / 10000;
//             IERC20(token).safeTransfer(splits[i].account, amount);
//         }
//     }
// }
