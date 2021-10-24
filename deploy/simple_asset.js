const hardhat = require('hardhat');
const { ethers } = hardhat;
const fs = require("fs")
const dotenv = require("dotenv")
dotenv.config()


const regDetails = ()=>{
    try{
        return JSON.parse(fs.readFileSync("./REGISTRATION_DETAILS.json").toString())
    } catch(err) {
        console.error("[ERROR] REGISTRATION_DETAILS file corrupted. New one will be auto-generated.", err)
        return {}
    }
}


// async function main() {
//     const ENV_CHECK = [
//         'DEPLOYER_PRIVATE_KEY',
//         'CONTRACT_NAME',
//         'CONTRACT_SYMBOL'
//     ]
//
// for(let [k, v] of Object.entries(process.env)) {
//         if(!ENV_CHECK.includes(k)) continue
//         if(v.startsWith('<') && v.endsWith('>')) {
//             console.error(`[ERROR] Replace ${k} value in .env with a valid one!`)
//             return process.exit(0)
//             }
//         }
//
//     const [deployer] = await ethers.getSigners();
//
//     const REG_DETAILS = regDetails()
//     REG_DETAILS.NETWORK = hardhat.network.name
//     REG_DETAILS.PUBLIC_KEY = await getPublicKey(deployer)
//     REG_DETAILS.OWNER_ADDRESS = deployer.address
//
//     console.log('Deploying Contracts with the account: ', REG_DETAILS.OWNER_ADDRESS);
//     console.log('Account Public Key', REG_DETAILS.PUBLIC_KEY);
//     console.log('Account Balance: ', (await deployer.getBalance()).toString());
//
//     // Use any logic you want to determine these values
//     const name = process.env.CONTRACT_NAME;
//     REG_DETAILS.COLLECTION_NAME = name;
//     const symbol = process.env.CONTRACT_SYMBOL;
//
//     REG_DETAILS.CONTRACT_ADDRESS = await deploySmartContract(name, symbol, hardhat.network.name);
//
//     console.log("[SUCCESS] Smart Contract deployed successfully.")
//     fs.writeFileSync("./REGISTRATION_DETAILS.json", JSON.stringify(REG_DETAILS, null, 4))
//     console.log("[INFO] Registration details have been stored in REGISTRATION_DETAILS.json")
// }

async function getPublicKey(signer){
    const message = 'x'
    const signed = await signer.signMessage(message)
    const digest = ethers.utils.arrayify(ethers.utils.hashMessage(message))
    return await ethers.utils.recoverPublicKey(digest, signed)
}

async function deploySmartContract(name, symbol, network) {
    // Hard coded to compile and deploy the Asset.sol smart contract.
    const SmartContract = await ethers.getContractFactory('Assets');
    const imxAddress = getIMXAddress(network);
    const smartContract = await SmartContract.deploy(name, symbol, imxAddress);

    console.log('Deployed Contract Address:', smartContract.address);
    console.log('Public address is ')
    return smartContract.address;
}

async function whiteListContract() {
    const SmartContract = await ethers.getContractFactory('Assets');
    const concAddr = await SmartContract.attach('0x473FAd8c61FcC53FDD8d02004E8DE6Ec54603e75');
    //concAddr.whiteListAddress('0xCEDC601D1E9696DD34C0F132812198E250109183');
//    console.log(await concAddr.isWhiteListed('0xCEDC601D1E9696DD34C0F132812198E250109183'));
    console.log(await concAddr.preSaleActiveTime());
    // console.log(await concAddr.setPreSaleTimeLimit(2));
    // console.log(await concAddr.preSaleActiveTime());
    console.log(await concAddr.isPreSaleActive())
    const tokenId = 121;
    const tokenURI = 'tokenURI';
    const blob = toHex(`{${tokenId}}:{${tokenURI}}`);
    console.log(blob);
    await concAddr.mintFor('0xCEDC601D1E9696DD34C0F132812198E250109183',1, blob);

}

function getIMXAddress(network) {
    switch (network) {
        case 'ropsten':
            return '0x4527be8f31e2ebfbef4fcaddb5a17447b27d2aef';
        case 'mainnet':
            return '0x5FDCCA53617f4d2b9134B29090C87D01058e27e9';
        case 'hardhat':
            // dummy address so the contract doesn't error out
            return '0x4527be8f31e2ebfbef4fcaddb5a17447b27d2aef';
    }
    throw Error('Invalid network selected');
}

function toHex(str) {
    let result = '';
    for (let i=0; i < str.length; i++) {
        result += str.charCodeAt(i).toString(16);
    }
    return '0x' + result;
}

function fromHex(str1) {
    let hex = str1.toString().substr(2);
    let str = '';
    for (let n = 0; n < hex.length; n += 2) {
        str += String.fromCharCode(parseInt(hex.substr(n, 2), 16));
    }
    return str;
}

const signer = ethers.getSigners();
//getPublicKey(signer)
// deploySmartContract('Dummy Contract','DC', hardhat.network.name)
whiteListContract()
.then(() => process.exit(0))
.catch((error) => {
    console.error("Error deploying the contract", error);
    process.exit(1);
});