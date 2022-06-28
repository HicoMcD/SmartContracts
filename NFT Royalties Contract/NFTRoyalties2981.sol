// "SPDX-License-Identifier: MIT"

pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract NFTRoyalties2981 is ERC721, Ownable, ERC721Enumerable, ERC721Royalty, ReentrancyGuard {
// Libraries
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    using Strings for uint256;

//Events
    event Deposit(address indexed sender, uint indexed amount, uint indexed balance);
    event Mint(address indexed sender, uint indexed amount, uint indexed _total); 
    event WhitelistAddresses(address[] indexed _users);

// Constants
    string public constant BASE_EXTENSION = ".json";
    uint public constant MAX_TOTAL_SUPPLY = 1111;
    uint public constant MAX_TOKEN_MINT = 10;
    uint public constant COST = 0.05 ether;
    string public constant PROVENANCE_URI = "INSERT COLLECTION CID";
    uint public PUBLIC_MINT_START = block.timestamp + 7 days;

// Mappings
    mapping(address => bool) public whitelistedAddresses;

// Initiate contract
    constructor() ERC721('NFTRoyalties2981', 'EIP2981') {
        _tokenIds.increment(); 
        _setDefaultRoyalty(owner(), 750);
    }

// Mint NFT
    function mint(uint _total) external payable nonReentrant mintingConditionals(_total) {
        require(PUBLIC_MINT_START < block.timestamp || verifyUser(msg.sender), "Public mint not available yet or not whitelisted");

        for(uint i = 0; _total > i; i++) 
        {
        require(totalSupply() < MAX_TOTAL_SUPPLY, "Total supply has been reached");

        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();

        _safeMint(msg.sender, tokenId);
        }
        emit Mint(msg.sender, msg.value, _total);
    }

// Whitelist multiple addresses
    function batchWhitelist(address[] memory _users) external onlyOwner {
 
        uint size = _users.length;
 
        for(uint256 i = 0; i < size; i++){
            address user = _users[i];
            whitelistedAddresses[user] = true;
        }
        emit WhitelistAddresses(_users);
    }

// Verify that a user is whitelisted
    function verifyUser(address _whitelistedAddress) public view returns(bool) {
      bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
      return userIsWhitelisted;
    }

// Withdraw from contract
    function withdraw(address payable _to, uint256 _amount) public payable onlyOwner {
        require(address(this).balance > 0, "No Ether in Contract");
        require(_amount > 0, "Cannot withdraw 0 amount");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

// Get contract balance
    function getBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }

// Creator to claim NFTs
    function creatorNFTClaims() public onlyOwner nonReentrant {
        require(totalSupply() == 0, "Creator NFTs have been claimed");

        for(uint i = 0; 11 > i; i++) 
        {
        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();

        _safeMint(msg.sender, tokenId);
        }
    }

// Fallback
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

// Modifiers

// Cost and Total conditional checks
    modifier mintingConditionals(uint _total) {
        require(msg.value == COST * _total, "Minting cost is 0.05 ETH per DSR NFT");
        require(_total <= MAX_TOKEN_MINT && _total > 0, "Must claim more than 0 but less than 11 DSR NFTs");   
        _;
    }

// FUNCTION OVERRIDES //
// Total current supply of NFTs
    function totalSupply() public view override returns (uint) {
        uint currentTokenId = _tokenIds.current();
        return currentTokenId - 1;
    }

// Set baseURI on deployment
    function _baseURI() internal pure override returns (string memory) {
        return PROVENANCE_URI; 
    }

// URI of chosen NFT
    function tokenURI(uint256 _tokenId) public view override(ERC721) returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query error. Token nonexistent");

        string memory currentBaseURI = _baseURI();
        return string(abi.encodePacked(currentBaseURI, _tokenId.toString(), BASE_EXTENSION));
    }

// Hook before transfer - Function not used
    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

// Burn token - Function not used
    function _burn(uint256 _tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(_tokenId);
    }

// Support Interface selection
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }
}