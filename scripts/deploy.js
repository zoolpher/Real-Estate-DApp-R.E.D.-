// const hre = require("hardhat");



const hre = require("hardhat");

async function main() {
    const [deployer] = await hre.ethers.getSigners(); // ethers v6 compatible

    console.log("Deploying contracts with account:", await deployer.getAddress());

    // -------------------------------
    //  Deploy MyERC1155 contract
    // -------------------------------
    const ERC1155 = await hre.ethers.getContractFactory("MyERC1155");
    const erc1155 = await ERC1155.deploy("https://token-cdn-domain/{id}.json"); // pass URI
    await erc1155.waitForDeployment(); // v6
    // console.log("MyERC1155 deployed at:", erc1155.target);

    // -------------------------------
    //  Deploy PropertyTokenizer contract
    // -------------------------------
    const PropertyTokenizer = await hre.ethers.getContractFactory("PropertyTokenizer");
    const propertyTokenizer = await PropertyTokenizer.deploy(erc1155.target);
    await propertyTokenizer.waitForDeployment();
    console.log("Seller approved WrappedERC1155 to transfer tokens");

    console.log("PropertyTokenizer deployed at:", propertyTokenizer.target);

    const tx = await erc1155.transferOwnership(propertyTokenizer.target);
    await tx.wait();
    console.log("ERC1155 ownership transferred to PropertyTokenizer");


    //--------------------------------
    //  Deploy WrappedERC1155 contract 
    //--------------------------------
    const WrappedERC1155 = await ethers.getContractFactory("WrappedERC1155", deployer);
    const wrappedNFT = await WrappedERC1155.deploy(deployer.getAddress());
    await wrappedNFT.waitForDeployment();
    const wrappedNFTAddress = await wrappedNFT.getAddress();
    console.log("WrappedERC1155 deployed at:", wrappedNFTAddress);

    // const approveTx = await propertyTokenizer.setApprovalForAll(
    //     wrappedNFTAddress,
    //     true
    // );
    // await approveTx.wait();
    // console.log("Approved WrappedERC1155 to transfer ERC1155 tokens");


    //--------------------------------
    //  Deploy Marketplace contract
    //--------------------------------
    // const ERC1155_ADDRESS = process.env.REACT_APP_ERC1155_ADDRESS; 
    const Marketplace = await hre.ethers.getContractFactory("Marketplace");
    const marketplace = await Marketplace.deploy(erc1155.target, wrappedNFT.target);
    await marketplace.waitForDeployment();


    
    // -------------------------------
    //  Deployment info summary
    // -------------------------------
    console.log("\n✅ Deployment completed successfully!");
    console.log("ERC1155 Address:", erc1155.target);
    console.log("PropertyTokenizer Address:", propertyTokenizer.target);
    console.log("Marketplace deployed at:", marketplace.target || marketplace.address);
    console.log("WrappedERC1155:", await wrappedNFT.getAddress());
}

// Execute the script
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
