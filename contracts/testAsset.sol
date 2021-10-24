pragma solidity ^0.7.6;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@imtbl/imx-contracts/contracts/Mintable.sol';
import '@imtbl/imx-contracts/contracts/utils/Minting.sol';

contract TestAssets is IMintable, Ownable, ERC721 {
    address public imx;
    uint public startTime;
    uint public preSaleActiveTime;
    uint public postSaleActiveTime;
    bool public paused;
    event TokenMint(address to, uint tokenID, bytes blueprint);
    mapping (address => uint) public preSaletokenLimit;
    mapping (address => uint) public postSaletokenLimit;
    mapping (uint => uint) public encodedWithTokenId;
    mapping (address => bool) public isWhiteListed;
    mapping (uint => bytes) public minting;

    constructor (
        string memory _name,
        string memory _symbol,
        address _imx
    ) ERC721 (_name, _symbol) {
        imx = _imx;
        startTime = block.timestamp;
    }

    modifier onlyIMX {
        msg.sender == imx;
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
    ) external override onlyIMX {
        require(quantity == 1,"Not more than 1");
        require (paused == false, "Contract Paused");
        (uint id, bytes memory blueprint) = Minting.split(mintingBlob);
        minting[id] = blueprint;
        require (tokenSale(to, id),"Not minted");
        emit TokenMint(to, id, blueprint);
    }

    function tokenSale (address _to, uint tokenId) internal returns (bool) {
        if (isPreSaleActive()) {
            require (isWhiteListed[_to], "Address not whitelisted");
            require (preSaletokenLimit[_to] <= 1, 'Purchase Limit Fullfilled');
            preSaletokenLimit[_to] = preSaletokenLimit[_to] + 1;
            _safeMint (_to, tokenId);
            _setTokenURI (tokenId, 'NONE');
            return true;
        }
        else {
            require (postSaletokenLimit[_to] <= 3, 'Limit Fulfilled');
            postSaletokenLimit[_to] = postSaletokenLimit[_to]+1;
            _safeMint (_to, tokenId);
            return true;
        }
    }

    function whiteListAddress (address _sender) external onlyOwner returns (bool) {
        return isWhiteListed[_sender] = true;
    }

    function setPreSaleTimeLimit (uint _day) external onlyOwner returns (uint) {
        preSaleActiveTime = _day;
        return preSaleActiveTime;
    }

    function pause() external onlyOwner returns (bool) {
        return paused = true;
    }


    function resume() external onlyOwner returns (bool) {
        return paused = false;
    }


    function setTokenURI (uint id, string memory tokenURI) public {
        require (block.timestamp >= startTime+ preSaleActiveTime * 1 days);
        require (isWhiteListed[_msgSender()],'Not white listed');
        _setTokenURI(id, tokenURI);
    }

}


