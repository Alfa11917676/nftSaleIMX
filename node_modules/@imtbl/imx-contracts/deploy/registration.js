
const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
  
    console.log("Deploying Contracts with the account:", deployer.address);
    console.log("Account Balance:", (await deployer.getBalance()).toString());

    await deploy('mainnet');
}

async function deploy(network) {
    const Registration = await ethers.getContractFactory("Registration");
    const imx_address = getIMXAddress(network);
    const asset = await Registration.deploy(imx_address);
    console.log("Deployed Contract Address:", asset.address);
}

function getIMXAddress(network) {
    switch (network) {
        case 'ropsten':
            return '0x4527be8f31e2ebfbef4fcaddb5a17447b27d2aef';
        case 'mainnet':
            return '0x5FDCCA53617f4d2b9134B29090C87D01058e27e9';
    }
    throw Error('Invalid network selected')
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});