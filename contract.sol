// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract LoadOutNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    uint256 public constant MAX_LOADOUT = 10000;
    uint256 public constant PRICE = 0.06 ether;
    uint256 public constant MAX_PER_MINT = 5;
    uint256 public constant PRESALE_MAX_MINT = 3;
    uint256 public constant MAX_LOADOUT_MINT = 50;
    uint256 public constant RESERVED_LOADOUTS = 50;
    address public constant founderAddress = ;
    address public constant cofounderAddress = ;

    uint256 public reservedClaimed;

    uint256 public numLoadoutsMinted;

    string public baseTokenURI;

    bool public publicSaleStarted;
    bool public presaleStarted;

    mapping(address => bool) private _presaleEligible;
    mapping(address => uint256) private _totalClaimed;

    event BaseURIChanged(string baseURI);
    event PresaleMint(address minter, uint256 amountOfLoadouts);
    event PublicSaleMint(address minter, uint256 amountOfLoadouts);

    modifier whenPresaleStarted() {
        require(presaleStarted, "Presale has not started");
        _;
    }

    modifier whenPublicSaleStarted() {
        require(publicSaleStarted, "Public sale has not started");
        _;
    }

    constructor(string memory baseURI) ERC721("LoadOutNFT", "LOADOUT") {
        baseTokenURI = baseURI;
    }

    function claimReserved(address recipient, uint256 amount) external onlyOwner {
        require(reservedClaimed != RESERVED_LOADOUTS, "Already have claimed all reserved loadouts");
        require(reservedClaimed + amount <= RESERVED_LOADOUTS, "Minting would exceed max reserved loadouts");
        require(recipient != address(0), "Cannot add null address");
        require(totalSupply() < MAX_LOADOUT, "All tokens have been minted");
        require(totalSupply() + amount <= MAX_LOADOUT, "Minting would exceed max supply");

        uint256 _nextTokenId = numLoadoutsMinted + 1;

        for (uint256 i = 0; i < amount; i++) {
            _safeMint(recipient, _nextTokenId + i);
        }
        numLoadoutsMinted += amount;
        reservedClaimed += amount;
    }

    function addToPresale(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            require(addresses[i] != address(0), "Cannot add null address");

            _presaleEligible[addresses[i]] = true;

            _totalClaimed[addresses[i]] > 0 ? _totalClaimed[addresses[i]] : 0;
        }
    }

    function checkPresaleEligiblity(address addr) external view returns (bool) {
        return _presaleEligible[addr];
    }

    function amountClaimedBy(address owner) external view returns (uint256) {
        require(owner != address(0), "Cannot add null address");

        return _totalClaimed[owner];
    }

    function mintPresale(uint256 amountOfLoadouts) external payable whenPresaleStarted {
        require(_presaleEligible[msg.sender], "You are not eligible for the presale");
        require(totalSupply() < MAX_LOADOUT, "All tokens have been minted");
        require(amountOfLoadouts <= PRESALE_MAX_MINT, "Cannot purchase this many tokens during presale");
        require(totalSupply() + amountOfLoadouts <= MAX_LOADOUT, "Minting would exceed max supply");
        require(_totalClaimed[msg.sender] + amountOfLoadouts <= PRESALE_MAX_MINT, "Purchase exceeds max allowed");
        require(amountOfLoadouts > 0, "Must mint at least one loadout");
        require(PRICE * amountOfLoadouts == msg.value, "ETH amount is incorrect");

        for (uint256 i = 0; i < amountOfLoadouts; i++) {
            uint256 tokenId = numLoadoutsMinted + 1;

            numLoadoutsMinted += 1;
            _totalClaimed[msg.sender] += 1;
            _safeMint(msg.sender, tokenId);
        }

        emit PresaleMint(msg.sender, amountOfLoadouts);
    }

    function mint(uint256 amountOfLoadouts) external payable whenPublicSaleStarted {
        require(totalSupply() < MAX_LOADOUT, "All tokens have been minted");
        require(amountOfLoadouts <= MAX_PER_MINT, "Cannot purchase this many tokens in a transaction");
        require(totalSupply() + amountOfLoadouts <= MAX_LOADOUT, "Minting would exceed max supply");
        require(_totalClaimed[msg.sender] + amountOfLoadouts <= MAX_LOADOUT_MINT, "Purchase exceeds max allowed per address");
        require(amountOfLoadouts > 0, "Must mint at least one loadout");
        require(PRICE * amountOfLoadouts == msg.value, "ETH amount is incorrect");

        for (uint256 i = 0; i < amountOfLoadouts; i++) {
            uint256 tokenId = numLoadoutsMinted + 1;

            numLoadoutsMinted += 1;
            _totalClaimed[msg.sender] += 1;
            _safeMint(msg.sender, tokenId);
        }

        emit PublicSaleMint(msg.sender, amountOfLoadouts);
    }

    function togglePresaleStarted() external onlyOwner {
        presaleStarted = !presaleStarted;
    }

    function togglePublicSaleStarted() external onlyOwner {
        publicSaleStarted = !publicSaleStarted;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseTokenURI;
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        baseTokenURI = baseURI;
        emit BaseURIChanged(baseURI);
    }

    function withdrawAll() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Insufficent balance");
        _widthdraw(cofounderAddress, ((balance * 50) / 100));
        _widthdraw(founderAddress, address(this).balance);
    }

    function _widthdraw(address _address, uint256 _amount) private {
        (bool success, ) = _address.call{ value: _amount }("");
        require(success, "Failed to widthdraw Ether");
    }
}