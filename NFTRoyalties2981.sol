// "SPDX-License-Identifier: MIT"

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
//import "@openzeppelin/contracts@4.6.0/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTRoyalties2981 is ERC721, Ownable, ERC721Royalty {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    using Strings for uint256;

    //Pre-reveal GIF URI
    string public defaultURI = "https://ipfs.io/ipfs/INSERT-IPFS-CID/";

    //Constants
    string public BASE_EXTENSION = ".json";
    uint public MAX_TOTAL_SUPPLY = 888;
    uint public COST = 0.1 ether;

    constructor() ERC721('NFTRoyalties2981', 'ROYAL') {
        _tokenIds.increment(); 
        _setDefaultRoyalty(owner(), 1000);
    }

    function _baseURI() internal view override returns (string memory) {
        return defaultURI;
    }

    function setDefaultURI(string memory _defaultURI) public onlyOwner {
        defaultURI = _defaultURI;
    }

    function MintRelic() external payable {
        require(msg.value == COST, "Minting cost is 0.1 Ether");
        require(totalSupply() <= MAX_TOTAL_SUPPLY, "Total supply has been reached");

        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();

        _safeMint(msg.sender, tokenId);
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIds.current();
    }

    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query error. Token nonexistent");

        string memory currentBaseURI = _baseURI();
        return string(abi.encodePacked(currentBaseURI, tokenId.toString(), BASE_EXTENSION));
    }
    function withdraw(address payable _to, uint256 amount) public payable onlyOwner {
        require(address(this).balance > 0, "No Ether in Contract");
        require(amount > 0, "Cannot withdraw 0 amount");

        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}