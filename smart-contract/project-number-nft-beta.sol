// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Project_Number_NFT_Beta is ERC721Enumerable, Ownable
{
    using Strings for uint256;
    
    string public baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.002 ether; // Cost to mint the NFT
    uint256 public maxSupply = 1000; // Total Supply
    uint256 public maxMintAmount = 20; // Max minting per user
    bool public saleActive = false;
    
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI
    ) ERC721(_name, _symbol)
    {
        setBaseURI(_initBaseURI);
    }
    
    // internal
    function _baseURI() internal view virtual override returns (string memory)
    {
        return baseURI;
    }

    // public
    function mint(address _to, uint256 _mintAmount) public payable
    {
        uint256 supply = totalSupply();
        
        require(saleActive, "Sales Not Active Yet!");
        require(_mintAmount > 0, "Mint Amount Error!");
        require(_mintAmount <= maxMintAmount, "Max Mint Amount Error!");
        require(supply + _mintAmount <= maxSupply, "Max Supply!");
        require(msg.value >= cost * _mintAmount, "Not enough ETH!");
        
        for (uint256 i = 0; i < _mintAmount; i++) 
        {
            while(_exists(supply + i)) 
            {
                i++;
            }
            _safeMint(_to, supply + i);
        }
    }

    function walletOfOwner(address _owner) public view returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) 
        {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return bytes(currentBaseURI).length > 0
            ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
            : "";
    }

    //only owner
    function withdraw(uint256 _value) public onlyOwner() {
        address payable to = payable(msg.sender);
        to.transfer(_value);
    }

    function withdrawAll() public onlyOwner() {
        uint256 balance = address(this).balance;
        address payable to = payable(msg.sender);
        to.transfer(balance);
    }

	function setCost(uint256 _newCost) public onlyOwner() 
    {
	    cost = _newCost;
	}
	
	function setMaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() 
    {
	    maxMintAmount = _newmaxMintAmount;
	}
	
	function setBaseURI(string memory _newBaseURI) public onlyOwner 
    {
	    baseURI = _newBaseURI;
	}

    function setSaleActive(bool _status) public onlyOwner {
        saleActive = _status;
    }
}
