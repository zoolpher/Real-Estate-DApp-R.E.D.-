# 🏠 Real Estate DApp (R.E.D.)

The Real Estate DApp is a decentralized platform that enables tokenization and trading of real-world properties on the blockchain. It combines ERC1155 (multi-token standard) for fractional ownership and ERC721 (NFT standard) for unique ownership, providing flexibility in how properties are represented and transferred.

## 🛠️ Tech Stack
- **Blockchain:** Solidity ⚡
- **Framework:** Hardhat 🛠️
- **Frontend:** React ⚛️
- **Wallet:** Coinbase 🔑

## Project Initializatin

Clone Repository:
`git clone https://github.com/your-username/real-estate-dapp.git`
`cd real-estate-dapp`

Install Dependencies:
`npm install`

`npm install --save-dev hardhat`

`npx hardhat --init`

`npx hardhat --version`
Hardhat version should be **(2.x.x)**

`npm install ethers`
Ethers js version should be **(v6)**

`npx create-react-app client`

## Testing

`npx hardhat node`
This will start a local Ethereum network at `http://127.0.0.1:8545/`
Import any of the given wallet private key to your `conbase wallet`.

`npx hardhat run scripts/deploy.js --network localhost`
Copy paste the contract address file you get after running the above command in .env

`cd client`
`npm start`
It will start the frontend.




## Supported by Team members:
- [https://github.com/garok17]https://github.com/garok17
- [https://github.com/Kisan062]https://github.com/Kisan062
