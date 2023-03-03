const { expect } = require("chai");
const { ethers } = require("hardhat");
const { utils } = ethers;
const { bigNumber } = ethers;
const { network } = require("hardhat");

describe("nft market place contract testing", async () => {
    let NftMarketPlace;
    let nftMarketPlace;
    let owner;
    let user1;
    let user2,user3;
    let mockERC721;
    let mockERC20;
    let liquidityPool;



    beforeEach("deploy all ERC20 and ERC721 contract", async () => {

        NftMarketPlace = await ethers.getContractFactory("NftMarketPlace");
        [owner, user1, user2,user3] = await ethers.getSigners();
        const mockerc721 = await ethers.getContractFactory("MyERC721Token");
        mockERC20 = await ethers.getContractFactory("MyERC20Token");
        const Pool = await ethers.getContractFactory(
            "MultiTokenLiquidityPool"
        );
        liquidityPool = await Pool.deploy();
        await liquidityPool.deployed();
        
        nftMarketPlace = await NftMarketPlace.deploy(
            ethers.utils.parseEther("0.001"),
            liquidityPool.address
            );
            await nftMarketPlace.deployed();
            
            mockERC20 = await mockERC20.deploy("daitoken", "DAI");
            await mockERC20.deployed();
            await liquidityPool.addToken(mockERC20.address);

        mockERC721 = await mockerc721.deploy("mynft", "NFT");
        await mockERC721.deployed();

    });


    it("should be able to List nfts on marketplace for sale", async () => {
        console.log(mockERC721);
        await mockERC721.safeMint(user1.address, "dfdf", 2);
        await mockERC721.connect(user1).approve(nftMarketPlace.address, 2);
        await nftMarketPlace.connect(user1).ListNft(mockERC721.address, 2, ethers.utils.parseEther("0.005"),20);
        const nftdetails = await nftMarketPlace.GetNftDetails(mockERC721.address,2);
        expect(nftdetails.price).to.equal(ethers.utils.parseEther("0.005"));
    })

    describe("buy with ERC20", function () {
        it("Should buy NFT correctly with ERC20 token", async function () {
            const amount = ethers.utils.parseEther("5", 18);

            // mint erc20 tokens to user2 and user3
            await mockERC20.mint(user2.address,ethers.utils.parseEther("10",18));
            await mockERC20.mint(user3.address,ethers.utils.parseEther("10", 18));

            expect(await mockERC20.balanceOf(user2.address)).to.equal(ethers.utils.parseEther("10", 18));
            // approve users token to liquidity pool
            await mockERC20.connect(user2).approve(liquidityPool.address, amount);
            await mockERC20.connect(user3).approve(liquidityPool.address, amount);
            // deposite users erc20token into liquidity pool
            await liquidityPool.connect(user2).deposit(mockERC20.address, amount);
            await liquidityPool.connect(user3).deposit(mockERC20.address, amount);
            console.log("user1 balance before nft purchase:", await liquidityPool.getBalance(user1.address,mockERC20.address));
            console.log("user2 balance before nft sell:",await liquidityPool.getBalance(user2.address,mockERC20.address));
            console.log("user3 balance before nft purchase:",await liquidityPool.getBalance(user3.address,mockERC20.address));

            await mockERC721.safeMint(user1.address, "dfdf", 5);
            expect(await mockERC721.ownerOf(5)).to.equal(user1.address);
            await mockERC721.connect(user1).approve(nftMarketPlace.address, 5);
            await nftMarketPlace.connect(user1).ListNft(mockERC721.address, 5, ethers.utils.parseEther("0.5",18),20);
            // user2 buy nft 
            await nftMarketPlace.connect(user2).Buy(mockERC721.address,5,mockERC20.address,ethers.utils.parseEther("0.87",18));
            console.log("user1 balance after  nft sell:",await liquidityPool.getBalance(user1.address,mockERC20.address));
            console.log("user2 balance after  nft purchase:",await liquidityPool.getBalance(user2.address,mockERC20.address));
            // this approval of current owner is nessasary for upcoming selling
            await mockERC721.connect(user2).approve(nftMarketPlace.address, 5);
            expect(await mockERC721.ownerOf(5)).to.equal(user2.address);

            console.log("owner of nft after sell", await mockERC721.ownerOf(5));

            await nftMarketPlace.connect(user3).Buy(mockERC721.address,5,mockERC20.address,ethers.utils.parseEther("0.5", 18));
            console.log("user1 final balance: ",await liquidityPool.getBalance(user1.address,mockERC20.address));
            console.log("user2 final balance:",await liquidityPool.getBalance(user2.address,mockERC20.address));
            console.log("user3 final balance:",await liquidityPool.getBalance(user3.address,mockERC20.address));
        });
    });

});
