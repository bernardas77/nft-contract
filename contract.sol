// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFT is ERC721, Ownable {
    using Strings for uint256;

    uint public price = 0; // 0.05 BNB

    uint256 public totalSupply = 0;

    string public baseUri;
    string public baseExtension = ".json";
    mapping(uint256 => string) private _tokenMetadata;

    constructor() ERC721("AI art", "ART") {
        baseUri = "https://gateway.pinata.cloud/ipfs/";
    }

    // Public Functions
    function setTokenMetadata(uint256 tokenId, string memory metadataHash) internal {
        require(_exists(tokenId), "Token ID does not exist");
        require(bytes(_tokenMetadata[tokenId]).length == 0, "Token metadata already set");
        _tokenMetadata[tokenId] = metadataHash;
    }


    function mint(string memory metadataHash) external payable returns (uint256){
        require(price <= msg.value, "Insufficient funds.");
        totalSupply++;
        _safeMint(msg.sender, totalSupply);
        setTokenMetadata(totalSupply, metadataHash);
        return totalSupply;
    }

    // Owner-only functions

    function setBaseUri(string memory _baseUri) external onlyOwner {
        baseUri = _baseUri;
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
    }

    function withdraw(uint256 _value) external payable onlyOwner {
        uint256 balance = address(this).balance;
        require(_value <= balance);
        ( bool transfer, ) = payable(msg.sender).call{value: _value}("");
        require(transfer, "Transfer failed.");
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory metadataHash = _tokenMetadata[tokenId];
        require(bytes(metadataHash).length > 0, "Token metadata hash is empty");

        return string(abi.encodePacked(_baseURI(), metadataHash));
    }
 
    function _baseURI() internal view virtual override returns (string memory) {
        return baseUri;
    }
}
