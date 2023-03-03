// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
// import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";
// import './Interfaces/IERC721.sol';
// import "./Interfaces/IERC20.sol";
import "./tokens/ERC721.sol";
import "./LiquidityPool.sol";
import "hardhat/console.sol";

contract NftMarketPlace {
    address public OWNER;
    uint120 public Platform_Fee;
    uint256 public Id;
    MultiTokenLiquidityPool public immutable LiquidityPoolAddress;

    // token to nft price
    mapping(uint256 => uint256) public NftPrice;

    // creator to contract address
    mapping(address => address) public Contract_Address;

    // contractAddress--->tokenId--->nftdetails
    mapping(address=>mapping(uint256 => NftParams)) public NftDetails;
    struct NftParams {
        address creator;
        bool ActiveToken;
        uint256 price;
        uint256 Royality; // in percentage
    }

    error NotOwner();
    error NoZeroAddress();
    error NoZeroPrice();

    event LogPlatformFee(
        uint256 indexed previousFee,
        uint256 indexed currentFee
    );
    event LogListed(
        address indexed PreviousOwner,
        address indexed CurrentOwner,
        uint256 indexed tokenId
    );

    constructor(uint120 _platformFee, address addr) payable {
        Platform_Fee = _platformFee;
        OWNER = msg.sender;
        LiquidityPoolAddress = MultiTokenLiquidityPool(addr);
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

    function ListNft(
        address nftAddress,
        uint256 _tokenId,
        uint256 _price,
        uint256 _royality
    ) external payable {
        // if (msg.value == Platform_Fee) revert NoZeroPrice();
        if (address(nftAddress) == address(0)) revert NoZeroAddress();
        require(msg.sender == IERC721(nftAddress).ownerOf(_tokenId),"Owner unauthorised");
        Id++;
        NftDetails[nftAddress][_tokenId] = NftParams(msg.sender,true,_price, _royality);
        Contract_Address[msg.sender]=nftAddress;
        emit LogListed(nftAddress, msg.sender, _tokenId);
    }

    // buyer can buy nft from liquidity pool
    function Buy(
        address nftAddress,
        uint256 _tokenId,
        address ERC20tokenAddress,
        uint256 amount
    ) external payable {
        NftParams memory nftdetails = NftDetails[nftAddress][_tokenId];
        require(nftdetails.ActiveToken, "token not listed");
        uint256 nftPrice = nftdetails.price;
        // need to verify nftprice with erc20 amount

        address ownerOfNft = IERC721(nftAddress).ownerOf(_tokenId);
        uint royalityFee=(amount*nftdetails.Royality)/100;
        MultiTokenLiquidityPool(LiquidityPoolAddress).Transfer(msg.sender,ownerOfNft,ERC20tokenAddress,amount-royalityFee);
        MultiTokenLiquidityPool(LiquidityPoolAddress).Transfer(msg.sender,nftdetails.creator,ERC20tokenAddress,amount-royalityFee );

        IERC721(nftAddress).transferFrom(ownerOfNft, msg.sender, _tokenId);
        require(IERC721(nftAddress).ownerOf(_tokenId) == msg.sender,"ownership tranfer failed");
    }

    function buy(address nftAddress, uint256 _tokenId) external payable {
        NftParams memory nftdetails = NftDetails[nftAddress][_tokenId];
        require(nftdetails.ActiveToken, "token not listed");
        uint256 nftPrice = nftdetails.price;
        address ownerOfNft = IERC721(nftAddress).ownerOf(_tokenId);
        require(msg.value == nftPrice, "incorrect amount");
        uint royalityFee=(nftPrice*nftdetails.Royality)/100;
        (bool success1, ) = payable(ownerOfNft).call{value: nftPrice-royalityFee}("");
        require(success1, "transfer failed");
        (bool success2, ) = payable(nftdetails.creator).call{value:royalityFee}("");
        require(success2, "transfer failed");
        IERC721(nftAddress).transferFrom(ownerOfNft, msg.sender, _tokenId);
        require(IERC721(nftAddress).ownerOf(_tokenId) == msg.sender,"ownership tranfer failed");
    }

    function SetNftprice(
        address nftcontract,
        uint256 tokenId,
        uint256 _Price
    ) external {
        require(msg.sender == IERC721(nftcontract).ownerOf(tokenId),"Owner Unauthorised");
        NftParams storage nftparm=NftDetails[nftcontract][tokenId];
        nftparm.price=_Price;
    }

    function getNftContract(address to) external view returns (address) {
        return Contract_Address[to];
    }
    function GetNftDetails(address nftAddress,uint _token) external view returns(address creator,bool Active,uint price, uint royality){
        NftParams memory nft=NftDetails[nftAddress][_token];
        creator=nft.creator;
        Active=nft.ActiveToken;
        price=nft.price;
        royality=nft.Royality;
    }
}
