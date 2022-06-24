// "SPDX-License-Identifier: MIT"

pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Royalty.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract NFTRoyalties2981 is ERC721, Ownable, ERC721Royalty, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    using Strings for uint256;

//Events
    event Deposit(address indexed sender, uint amount, uint balance);
    //MintNFT
    //Withdraw

// Constants
    string public constant BASE_EXTENSION = ".json";
    uint public constant MAX_TOTAL_SUPPLY = 1111;
    uint public constant MAX_TOKEN_MINT = 10;
    uint public constant COST = 0.05 ether;
    string public constant PROVENANCE_URI = "INSERT URI/";

// Mappings
    mapping(address => bool) public whitelistedAddresses;

// Initiate contract
    constructor() ERC721('NFTRoyalties2981', 'EIP2981') {
        _tokenIds.increment(); 
        _setDefaultRoyalty(owner(), 750);
    }

// Mint NFT
    function MintNFT(uint amount) external payable nonReentrant {
        require(msg.value == COST * amount, "Not enough to pay for minting cost");
        require(amount <= MAX_TOKEN_MINT && amount > 0, "Must claim more than 0 but less than 11 NFTs");

        for(uint i = 0; amount > i; i++) 
        {
        require(totalSupply() < MAX_TOTAL_SUPPLY, "Total supply has been reached");

        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();

        _safeMint(msg.sender, tokenId);
        }
    }

// Total current supply of NFTs
    function totalSupply() public view returns (uint) {
        uint currentTokenId = _tokenIds.current();
        return currentTokenId - 1;
    }

// Creator to claim NFTs
    function creatorNFTClaims() public nonReentrant {
        require(totalSupply() == 0, "Creator NFTs");

        for(uint i = 0; 11 > i; i++) 
        {
        uint256 tokenId = _tokenIds.current();
        _tokenIds.increment();

        _safeMint(msg.sender, tokenId);
        }
    }

// Withdraw from contract
    function withdraw(address payable _to, uint256 amount) public payable onlyOwner {
        require(address(this).balance > 0, "No Ether in Contract");
        require(amount > 0, "Cannot withdraw 0 amount");

        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    function addUser(address _addressToWhitelist) public onlyOwner {
      whitelistedAddresses[_addressToWhitelist] = true;
    }

    // function verifyUser(address _whitelistedAddress) public view returns(bool) {
    //   bool userIsWhitelisted = whitelistedAddresses[_whitelistedAddress];
    //   return userIsWhitelisted;
    // }
    function batchWhitelist(address[] memory _users) external onlyOwner {
 
        uint size = _users.length;
 
        for(uint256 i = 0; i < size; i++){
            address user = _users[i];
            whitelistedAddresses[user] = true;
   }
 }

// Modifiers
    modifier isWhitelisted(address _address) {
      require(whitelistedAddresses[_address], "Whitelist: You need to be whitelisted");
      _;
    }


// FUNCTION OVERRIDES //
// Set baseURI before contract deployed
    function _baseURI() internal pure override returns (string memory) {
        return PROVENANCE_URI; 
    }

// URI of chosen NFT
    function tokenURI(uint256 tokenId) public view override(ERC721) returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query error. Token nonexistent");

        string memory currentBaseURI = _baseURI();
        return string(abi.encodePacked(currentBaseURI, tokenId.toString(), BASE_EXTENSION));
    }

// Burn token
    function _burn(uint256 tokenId) internal override(ERC721, ERC721Royalty) {
        super._burn(tokenId);
    }

// Support Interfaceselection
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Royalty)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
