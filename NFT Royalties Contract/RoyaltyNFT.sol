// "SPDX-License-Identifier: MIT"

pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract RoyaltyNFT is ERC721, Ownable, ERC721Royalty, ReentrancyGuard {
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
    uint public WHITELIST_MINT = block.timestamp + 14 days;
    uint public PUBLIC_MINT_START = WHITELIST_MINT + 14 days;
    uint public ARTWORK_REVEAL = PUBLIC_MINT_START + 7 days;
    uint public GUARANTEE_PROVENANCE = ARTWORK_REVEAL + 1 days;
    
// Variables
    // Pre-reveal GIF
    string public PROVENANCE_URI = "INSERT PRE-REVEAL URI";  

// Booleans
    // Pre-reveal activation
    bool public PREREVEAL_ACTIVE = true;

// Mappings
    mapping(address => bool) private whitelistedAddresses;

// Initiate contract
    constructor() ERC721('Royalty NFT', 'ROYLT') {
        _tokenIds.increment(); 
        _setDefaultRoyalty(owner(), 750);
    }

// Mint NFT
    function mint(uint _total) external payable nonReentrant mintingConditionals(_total) {
        require(WHITELIST_MINT < block.timestamp && verifyUser(msg.sender), "Your address is not whitelisted or Whitelist minting is not available yet");
        require(PUBLIC_MINT_START < block.timestamp, "Public mint not available yet");

        for(uint i = 0; _total > i; i++) 
        {
        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();

        _safeMint(msg.sender, tokenId);
        }
        emit Mint(msg.sender, msg.value, _total);
    }

// Whitelist multiple addresses
    function batchWhitelist(address[] memory _users) external onlyOwner {
        require(PUBLIC_MINT_START < block.timestamp, "Public mint has already started");
 
        uint size = _users.length;
 
        for(uint256 i = 0; i < size; i++){
            address user = _users[i];
            whitelistedAddresses[user] = true;
        }
        emit WhitelistAddresses(_users);
    }

// Verify that a user is whitelisted
    function verifyUser(address _whitelistedAddress) public view returns(bool) {
        return whitelistedAddresses[_whitelistedAddress];
    }

// Withdraw from contract
    function withdraw(address payable _to, uint256 _amount) public onlyOwner {
        require(address(this).balance > 0, "No Ether in Contract");
        require(_amount > 0, "Cannot withdraw 0 amount");
        require(_amount <= address(this).balance, "Cannot withdraw more than balance of Contract");

        (bool sent, ) = _to.call{value: _amount}("");
        require(sent, "Failed to send Ether");
    }

// Get contract balance
    function getBalance() public view onlyOwner returns(uint) {
        return address(this).balance;
    }
    
// Total current supply of NFTs
    function totalSupply() public view returns (uint) {
    	return _tokenIds.current() - 1;
    }
    
// Change Provenance URI from preview image/GIF to actual artwork URI "INSERT ARTWORK URI" below 
    function setProvenanceURI(string memory _provenanceURI) public onlyOwner {
        PROVENANCE_URI = _provenanceURI;
        PREREVEAL_ACTIVE = false;
    }

// Creator to claim NFTs
    function creatorNFTClaims() public payable onlyOwner nonReentrant {
        require(totalSupply() == 0, "Creator NFTs have been claimed");

        for(uint i = 0; 11 > i; i++) 
        {
        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();

        _safeMint(msg.sender, tokenId);
        }
// For Event emitting
        uint _total = 11;
        
        emit Mint(msg.sender, msg.value, _total);
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
         
        uint currentSupply = totalSupply() + _total;
        require(currentSupply < MAX_TOTAL_SUPPLY, "Total supply has been reached or minting more than Total Supply allowed");
        _;
    }

// FUNCTION OVERRIDES //

// Set baseURI on deployment
    function _baseURI() internal view override returns (string memory) {
        require(GUARANTEE_PROVENANCE > block.timestamp, "Provenance is now Guaranteed");
        return PROVENANCE_URI; 
    }

// URI of chosen NFT
    function tokenURI(uint256 _tokenId) public view override(ERC721) returns (string memory) {
        require(_exists(_tokenId), "ERC721Metadata: URI query error. Token nonexistent");

        if(ARTWORK_REVEAL < block.timestamp && !PREREVEAL_ACTIVE) {
            string memory currentBaseURI = _baseURI();
            return string(abi.encodePacked(currentBaseURI, _tokenId.toString(), BASE_EXTENSION));
        }

        return PROVENANCE_URI;
    }

// Burn token - Function not used
    function _burn(uint256 _tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(_tokenId);
    }

// Support Interface selection
    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(ERC721, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }
}
