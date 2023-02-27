// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
// import './Interfaces/IERC721.sol';
import "./Interfaces/IERC20.sol";
import "./tokens/ERC721.sol";

contract NftMarketPlace {
    address public OWNER;
    uint120 public Platform_Fee;
    uint256 public Token_Id;

    // price of nft
    struct Nft_Price {
        uint256 price_in_DAI;
        uint256 price_in_USDT;
        uint256 price_in_WBTC;
        uint256 price_in_ETH;
    }
    // token to nft price
    mapping(uint256 => Nft_Price) public NftPrice;

    // creator to contract address
    mapping(address => MyERC721Token) public Contract_Address;

    error NotOwner();
    error NoZeroAddress();

    event LogPlatformFee(
        uint256 indexed previousFee,
        uint256 indexed currentFee
    );

    constructor(uint120 _platformFee) payable {
        Platform_Fee = _platformFee;
        OWNER = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != OWNER) revert NotOwner();
        _;
    }

    function setFee(uint120 _platformfee) external payable onlyOwner {
        uint256 fee = _platformfee;
        Platform_Fee = _platformfee;
        emit LogPlatformFee(fee, _platformfee);
    }

    function MintNft(
        string memory _name,
        string memory _symbol,
        string memory uri,
        uint256 initial_supply
    ) external {
        MyERC721Token addr = Contract_Address[msg.sender];
        if (address(addr) == address(0)) {
            MyERC721Token NFTaddr = new MyERC721Token(_name, _symbol);
            Contract_Address[msg.sender] = NFTaddr;
            addr = NFTaddr;
        }

        for (uint256 i; i < initial_supply; ++i) {
            Token_Id++;
            MyERC721Token(addr).safeMint(msg.sender, uri, Token_Id);
        }
    }


    function SetNftprice(
        MyERC721Token nftcontract,
        uint256 tokenId,
        uint256 price_in_DAI,
        uint256 price_in_USDT,
        uint256 price_in_WBTC,
        uint256 price_in_ETH
    ) private {
        // require(msg.sender==MyERC721Token(nftcontract).ownerOf(tokenId),"Owner Unauthorised");
        NftPrice[tokenId] = Nft_Price(
            price_in_DAI,
            price_in_USDT,
            price_in_WBTC,
            price_in_ETH
        );
    }

    function getNftContract() external view returns (MyERC721Token) {
        return Contract_Address[msg.sender];
    }


     function getNftdetails(MyERC721Token nftcontract,address to,uint _tokenId) external view returns(string memory name, string memory symbol, uint256 balance,address owner,string memory uri){
        name=nftcontract.name();
        symbol=nftcontract.symbol();
        balance=nftcontract.balanceOf(to);
        owner=nftcontract.ownerOf(_tokenId);
        uri= nftcontract.tokenURI(_tokenId);
    }
}
