//SPDX-License-Identifier: MIT
pragma solidity 0.7.6;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";
import "hardhat/console.sol";

contract UniswapV3Twap {
    address public  token0;
    address public  token1;

    address public  pool;
    uint24 _fee;
    address public Factory;

    event LogSetFactory(address indexed factoryAddress);


    // modifier Onlyowner(){
    //     require(msg.sender==OWNER,"owner Unauthorized");
    //     _;
    // }
    function SetFactory(address _factory) external {
        Factory=_factory;
        emit LogSetFactory( _factory);
    }

    //@dev find price of tokenIn in terms of tokenOut for amountIn
    //@pram tokenIn is basic input token address
    // @pram tokenout is token address(price that want)
    //@pram amountIn is amount of input token that need to convert in tokenout
    //@pram secondsAgo , calculate TWAP for given time interval
    //@_fee fee tiers of pool in factory
    function estimateAmountOut(
        address tokenIn,
        address tokenout,
        uint128 amountIn,
        uint32 secondsAgo,
        uint24 _fee
    ) external view returns (uint amountOut) {
        address pool = IUniswapV3Factory(Factory).getPool(tokenIn,tokenout,_fee);
        require(pool != address(0), "pool doesn't exist");
        uint32[] memory secondsAgos = new uint32[](2);
        secondsAgos[0] = secondsAgo;
        secondsAgos[1] = 0;

        // int56 since tick * time = int24 * uint32
        // 56 = 24 + 32
        (int56[] memory tickCumulatives, ) = IUniswapV3Pool(pool).observe(secondsAgos);

        int56 tickCumulativesDelta = tickCumulatives[1] - tickCumulatives[0];

        // int56 / uint32 = int24
        int24 tick = int24(tickCumulativesDelta / secondsAgo);
        // Always round to negative infinity
        /*
        int doesn't round down when it is negative

        int56 a = -3
        -3 / 10 = -3.3333... so round down to -4
        but we get
        a / 10 = -3

        so if tickCumulativeDelta < 0 and division has remainder, then round
        down
        */
        if (tickCumulativesDelta < 0 && (tickCumulativesDelta % secondsAgo != 0)) {tick--;}

        amountOut = OracleLibrary.getQuoteAtTick(tick,amountIn,tokenIn,tokenout);
    }
}
