pragma solidity ^0.7.6;


import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@imtbl/imx-contracts/contracts/Mintable.sol';
import '@imtbl/imx-contracts/contracts/utils/Minting.sol';
import '@openzeppelin/contracts/math/SafeMath.sol';


contract Assets is IMintable, ERC721 {
    using SafeMath for uint;
    address public imx;
    uint public startTime;
    uint public preSaleActiveTime;
    uint public postSaleActiveTime;
    event TokenMint(address to, uint tokenID, bytes blueprint);
    mapping (address => uint) public preSaletokenLimit;
    mapping (address => uint) public postSaletokenLimit;
    mapping (address => bool) public isWhiteListed;
    mapping (uint => bytes) public minting;
//    uint public preSalePrice = 0.035 * 1 ether;
//    uint public postSalePrice = 0.05 * 1 ether;
//    mapping (address => uint) public valueReceived;
//    checking will be done in the backend
    address private owner;


    constructor (
        address _imx
        ) ERC721 ('IMX PUNKS', 'IP'

    ) {
                 imx = _imx;
                 startTime = block.timestamp;
                 owner = msg.sender;
        }
    address payable private receiver = payable(0xCEDC601D1E9696DD34C0F132812198E250109183);
    address payable private secondOwner = payable(0x0F06707E5E4f7329d2497121d536479c3c4F1129);

    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }


    function isPreSaleActive() public view returns (bool) {
           if (block.timestamp <= (startTime+(preSaleActiveTime * 1 days))) {
                return true;
            }else {
                return false;
            }
    }


    function mintFor(
        address to,
        uint256 quantity,
        bytes calldata mintingBlob
    ) external override {
        require(quantity == 1,"Not more than 1");
        (uint id, bytes memory blueprint) = Minting.split(mintingBlob);
        minting[id] = blueprint;
        tokenSale(to, id);
        emit TokenMint(to, id, blueprint);
    }


    function tokenSale (address _to, uint tokenId) internal returns (bool) {
        if (isPreSaleActive()) {
            require (preSaletokenLimit[_to] <= 1, 'Purchase Limit Fullfilled');
            //require (valueReceived[msg.sender]>= preSalePrice);
            //valueReceived[msg.sender] = valueReceived[msg.sender].sub(preSalePrice);
            //checking will be done in the backend
            preSaletokenLimit[_to] = preSaletokenLimit[_to] + 1;
            _safeMint (_to, tokenId);
            _setTokenURI (tokenId, 'https://gateway.pinata.cloud/ipfs/QmQ5KhMFkAgA1mqdsbrXjQTu9UDGV8rnpdmiPNBiWPFrKf');
            return true;
        }
        else {
            require (postSaletokenLimit[_to] <= 5, 'Limit Fulfilled');
            //require (valueReceived[msg.sender] >= postSalePrice);
            //valueReceived[msg.sender] = valueReceived[msg.sender].sub(postSalePrice);
            //checking will be done in the backend
            postSaletokenLimit[_to] = postSaletokenLimit[_to]+1;
            _safeMint (_to, tokenId);
            _setTokenURI (tokenId, 'https://gateway.pinata.cloud/ipfs/QmQ5KhMFkAgA1mqdsbrXjQTu9UDGV8rnpdmiPNBiWPFrKf');
            return true;
        }
    }


    function whiteListAddress (address _sender) external onlyOwner {
        isWhiteListed[_sender] = true;
    }


    function setPreSaleTimeLimit (uint _day) external onlyOwner {
        preSaleActiveTime = _day;
    }


    function setTokenURI (uint id, string memory tokenURI) external onlyOwner {
                require (block.timestamp >= startTime+ preSaleActiveTime * 1 days);
                require (isWhiteListed[_msgSender()],'Not white listed');
                _setTokenURI (id, tokenURI);
    }


    function retrieveBalance () public onlyOwner payable {
            receiver.transfer((address(this).balance).div(2));
            secondOwner.transfer(address(this).balance);
    }


    fallback () external payable {
        retrieveBalance();
    }
}