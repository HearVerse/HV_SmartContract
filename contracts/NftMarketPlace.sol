// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;

// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
// import "@openzeppelin/contracts/security/Pausable.sol";
// import './Interfaces/IERC721.sol';
// import "./Interfaces/IERC20.sol";
import "./tokens/ERC721.sol";
import "./LiquidityPool.sol";

contract NftMarketPlace {
    address public OWNER;
    uint120 public Platform_Fee;
    uint256 public Token_Id;
    MultiTokenLiquidityPool public immutable LiquidityPoolAddress;

    // token to nft price
    mapping(uint256 => uint256) public NftPrice;

    // creator to contract address
    mapping(address => MyERC721Token) public Contract_Address;
    mapping(uint256 => bool) public ActiveToken;

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

    function ListNft(
        MyERC721Token nftAddress,
        uint256 _tokenId,
        uint256 _price
    ) external payable {
        if (msg.value == Platform_Fee) revert NoZeroPrice();
        if (address(nftAddress) == address(0)) revert NoZeroAddress();
        NftPrice[_tokenId] = _price;
        MyERC721Token(nftAddress).approve(address(this), _tokenId);
        ActiveToken[_tokenId] = true;
        // IERC721(nftAddress).transferFrom(msg.sender,address(this),_tokenId);
        emit LogListed(address(nftAddress), msg.sender, _tokenId);
    }

    // buyer can buy nft from liquidity pool
    function buy(
        MyERC721Token nftAddress,
        uint256 _tokenId,
        address ERC20tokenAddress,
        uint256 amount
    ) external payable {
        uint256 nftPrice = NftPrice[_tokenId];

        // need to verify nft price from argument

        address ownerOfNft = IERC721(nftAddress).ownerOf(_tokenId);
        MultiTokenLiquidityPool(LiquidityPoolAddress).transfer(
            ownerOfNft,
            ERC20tokenAddress,
            amount
        );
        IERC721(nftAddress).transferFrom(ownerOfNft, msg.sender, _tokenId);
        require(
            IERC721(nftAddress).ownerOf(_tokenId) == msg.sender,
            "ownership tranfer failed"
        );
        IERC721(nftAddress).approve(address(this), _tokenId);
    }

    function buy(MyERC721Token nftAddress, uint256 _tokenId) external payable {
        uint256 nftPrice = NftPrice[_tokenId];
        require(msg.value == nftPrice, "incorrect amount");
        address ownerOfNft = IERC721(nftAddress).ownerOf(_tokenId);
        (bool success, ) = payable(ownerOfNft).call{value: msg.value}("");
        require(success, "transfer failed");
        IERC721(nftAddress).transferFrom(ownerOfNft, msg.sender, _tokenId);
        require(
            IERC721(nftAddress).ownerOf(_tokenId) == msg.sender,
            "ownership tranfer failed"
        );
        IERC721(nftAddress).approve(address(this), _tokenId);
    }

    function SetNftprice(
        address nftcontract,
        uint256 tokenId,
        uint256 _Price
    ) external {
        require(
            msg.sender == IERC721(nftcontract).ownerOf(tokenId),
            "Owner Unauthorised"
        );
        NftPrice[tokenId] = _Price;
    }

    function getNftContract() external view returns (MyERC721Token) {
        return Contract_Address[msg.sender];
    }

    function getNftdetails(
        MyERC721Token nftcontract,
        address to,
        uint256 _tokenId
    )
        external
        view
        returns (
            string memory name,
            string memory symbol,
            uint256 balance,
            address owner,
            string memory uri
        )
    {
        name = nftcontract.name();
        symbol = nftcontract.symbol();
        balance = nftcontract.balanceOf(to);
        owner = nftcontract.ownerOf(_tokenId);
        uri = nftcontract.tokenURI(_tokenId);
    }
}
