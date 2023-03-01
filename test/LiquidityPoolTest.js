const { expect } = require("chai");
const { ethers } = require("hardhat");
const { utils } = ethers;
const { bigNumber } = ethers;
const { network } = require("hardhat");

describe("MultiTokenLiquidityPool", function () {
    let liquidityPool;
    let daiToken;
    let usdcToken;
    let owner;
    let user1;
    let user2;

    beforeEach(async function () {
        [owner, user1, user2] = await ethers.getSigners();

        const MultiTokenLiquidityPool = await ethers.getContractFactory(
            "MultiTokenLiquidityPool"
        );
        liquidityPool = await MultiTokenLiquidityPool.deploy();
        await liquidityPool.deployed();

        const ERC20Token = await ethers.getContractFactory("MyERC20Token");

        daiToken = await ERC20Token.deploy("DAI", "DAI");
        await daiToken.deployed();
        await daiToken.mint(user1.address, ethers.utils.parseUnits("1000", 18));
        await daiToken.mint(user2.address, ethers.utils.parseUnits("1000", 18));

        usdcToken = await ERC20Token.deploy("USDC", "USDC");
        await usdcToken.deployed();
        await usdcToken.mint(user1.address, ethers.utils.parseUnits("1000", 6));
        await usdcToken.mint(user2.address, ethers.utils.parseUnits("1000", 6));
    });

    it("should allow the owner to add and remove tokens", async function () {
        const token = daiToken.address;

        // Verify that the token is not supported before adding it
        const isTokenSupportedBefore = await liquidityPool.tokens(token);
        expect(isTokenSupportedBefore).to.equal(false);

        // Add the token and verify that it is now supported
        await liquidityPool.addToken(token);
        const isTokenSupportedAfterAdd = await liquidityPool.tokens(token);
        expect(isTokenSupportedAfterAdd).to.equal(true);

        // Remove the token and verify that it is no longer supported
        await liquidityPool.removeToken(token);
        const isTokenSupportedAfterRemove = await liquidityPool.tokens(token);
        expect(isTokenSupportedAfterRemove).to.equal(false);
    });

    it("should allow users to deposit and withdraw tokens", async function () {
        const amount = ethers.utils.parseUnits("100", 18);

        // User 1 deposits DAI into the liquidity pool
        // Add the token that it is now supported
        await liquidityPool.addToken(daiToken.address);
        await daiToken.connect(user1).approve(liquidityPool.address, amount);
        await liquidityPool.connect(user1).deposit(daiToken.address, amount);
        const user1DaiBalanceAfterDeposit = await liquidityPool.getBalance(
            user1.address,
            daiToken.address
        );
        expect(user1DaiBalanceAfterDeposit).to.equal(amount);
        // total asset(dai) in liquidity pool.
        expect(await daiToken.balanceOf(liquidityPool.address)).to.equal(
            ethers.utils.parseUnits("100", 18)
        );

        // User 1 withdraws DAI from the liquidity pool
        await liquidityPool.connect(user1).withdraw(daiToken.address, amount);
        const user1DaiBalanceAfterWithdrawal = await liquidityPool.getBalance(
            user1.address,
            daiToken.address
        );
        expect(user1DaiBalanceAfterWithdrawal).to.equal(0);
        // total asset(dai) in liquidity pool after withdraw.
        expect(await daiToken.balanceOf(liquidityPool.address)).to.equal(0);

        //         // User 2 deposits USDC into the liquidity pool
        //         // Add the token and verify that it is now supported
        await liquidityPool.addToken(usdcToken.address);
        await usdcToken.connect(user2).approve(liquidityPool.address, amount);
        const usdcamount = ethers.utils.parseUnits("1000", 6);
        await liquidityPool.connect(user2).deposit(usdcToken.address, usdcamount);
        const user2UsdcBalanceAfterDeposit = await liquidityPool.getBalance(
            user2.address,
            usdcToken.address
        );
        expect(user2UsdcBalanceAfterDeposit).to.equal(usdcamount);
        // total asset(usdc) in liquidity pool.
        expect(await usdcToken.balanceOf(liquidityPool.address)).to.equal(
            ethers.utils.parseUnits("1000", 6)
        );
        // User 2 withdraws USDC from the liquidity pool
        await liquidityPool.connect(user2).withdraw(usdcToken.address, usdcamount);
        const user2UsdcBalanceAfterWithdrawal = await liquidityPool.getBalance(
            user2.address,
            usdcToken.address
        );
        expect(user2UsdcBalanceAfterWithdrawal).to.equal(0);
        // total asset(dai) in liquidity pool after withdraw.
        expect(await daiToken.balanceOf(liquidityPool.address)).to.equal(0);
    });

    it("should allow transfer of asset in liquidity pool to other user", async () => {
        const amount = ethers.utils.parseUnits("100", 18);

        console.log(
            "dai token of user1 before deposite in liquidity pool",
            await daiToken.balanceOf(user1.address)
        );
        expect(await daiToken.balanceOf(user1.address)).to.equal(
            ethers.utils.parseUnits("1000", 18)
        );
        console.log(
            "dai token of user2 before deposite in liquidity pool",
            await daiToken.balanceOf(user2.address)
        );
        expect(await daiToken.balanceOf(user2.address)).to.equal(
            ethers.utils.parseUnits("1000", 18)
        );

        console.log(
            "total dai token in liquidity pool",
            await daiToken.balanceOf(liquidityPool.address)
        );
        expect(await daiToken.balanceOf(liquidityPool.address)).to.equal(0);
        // User 1 deposits DAI into the liquidity pool
        // Add the token that it is now supported
        await liquidityPool.addToken(daiToken.address);
        await daiToken.connect(user1).approve(liquidityPool.address, amount);
        await liquidityPool.connect(user1).deposit(daiToken.address, amount);
        console.log(
            "dai token of user1 after deposite in liquidity pool",
            await daiToken.balanceOf(user1.address)
        );
        expect(await daiToken.balanceOf(user1.address)).to.equal(
            ethers.utils.parseUnits("900", 18)
        );

        expect(
            await liquidityPool.getBalance(user1.address, daiToken.address)
        ).to.equal(amount);
        expect(
            await liquidityPool.getBalance(user2.address, daiToken.address)
        ).to.equal(0);
        expect(await daiToken.balanceOf(liquidityPool.address)).to.equal(amount);
        await liquidityPool
            .connect(user1)
            .transfer(user2.address, daiToken.address, amount);

        expect(
            await liquidityPool.getBalance(user1.address, daiToken.address)
        ).to.equal(0);

        expect(
            await liquidityPool.getBalance(user2.address, daiToken.address)
        ).to.equal(amount);
    });
});
