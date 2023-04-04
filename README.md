# LiquidityPool.sol

**Overview**

LiquidityPool.sol is a smart contract that allows users to deposit and withdraw ERC20 tokens into a liquidity pool. The contract keeps track of the balance of each user for each token they deposit. Additionally, users can transfer tokens between each other within the liquidity pool. This contract can be used as the basis for a decentralized exchange or a liquidity pool for a lending protocol.

**Contract Details**

The following are the functions and variables available in the contract:

Variables

- **balances**: A mapping of the user address to the token address to the amount of tokens they have deposited in the liquidity pool.
- **tokens**: A mapping of the token address to a boolean value indicating if the token is supported in the liquidity pool.
- **owner**: The address of the owner of the contract.

Events

- **LogDeposite**: Emitted when a user deposits tokens into the liquidity pool.
- **LogWithdraw**: Emitted when a user withdraws tokens from the liquidity pool.
- **LogTransfer**: Emitted when a user transfers tokens to another user within the liquidity pool.

Modifiers

- **onlyOwner**: Modifier that restricts the function to be called only by the owner of the contract.

Functions

**addToken(address token) external onlyOwner**

This function adds a new token to the liquidity pool. It takes in a **token** address as a parameter and adds it to the **tokens** mapping with a value of **true**. Only the contract owner can call this function.

**removeToken(address token) external onlyOwner**

This function removes a token from the liquidity pool. It takes in a **token** address as a parameter and sets the value in the **tokens** mapping to **false**. Only the contract owner can call this function.

**deposit(address token, uint256 amount) external**

This function allows a user to deposit **amount** of **token** into the liquidity pool. It requires that the **token** is supported in the liquidity pool and that the user has approved the contract to transfer **amount** of **token** from their account. Once the tokens are transferred, the function updates the **balances** mapping for the user and emits a **LogDeposite** event.

**withdraw(address token, uint256 amount) external**

This function allows a user to withdraw **amount** of **token** from the liquidity pool. It requires that the user has a balance of at least **amount** of **token** in the liquidity pool. Once the tokens are transferred back to the user's account, the function updates the **balances** mapping for the user and emits a **LogWithdraw** event.

**Transfer(address from, address to, address token, uint256 amount) external**

This function allows a user to transfer **amount** of **token** from their balance to another user's balance in the liquidity pool. It requires that the **token** is supported in the liquidity pool and that the user has a balance of at least **amount** of **token**. Once the transfer is complete, the function updates the **balances** mapping for both users and emits a **LogTransfer** event.

**getBalance(address account, address token) external view returns (uint256)**

This function returns the balance of **token** for the **account**.

**withdrawAll(address[] calldata tokensList) external**

This function allows a user to withdraw all of their tokens from the liquidity pool. It takes in an array of token addresses and transfers the balance of each token back to the user's account. If the user has a balance of 0 for a given token

# LiquidityPoolTest.js

is a test file written in JavaScript to test the functionalities of the MultiTokenLiquidityPool smart contract.

The test file imports required modules and libraries such as **chai**, **ethers**, and **hardhat**. It contains three test cases, each testing a specific functionality of the **MultiTokenLiquidityPool** contract.

- The first test case checks whether the owner can add and remove tokens from the liquidity pool. It checks that a token is not supported before adding it, adds the token to the liquidity pool, and then checks that it is now supported. It also removes the token from the liquidity pool and checks that it is no longer supported.
- The second test case tests whether users can deposit and withdraw tokens from the liquidity pool. It checks that a user can deposit a specific amount of a token into the liquidity pool, and then checks that the balance of the user in the liquidity pool is updated accordingly. It also checks that the total asset in the liquidity pool is updated correctly. The test case then withdraws the deposited token amount from the liquidity pool, checks that the balance of the user in the liquidity pool is zero, and that the total asset in the liquidity pool is also zero.
- The third test case checks whether users can transfer assets in the liquidity pool to other users. It checks the balance of two users before and after depositing assets into the liquidity pool and transferring the assets from one user to another. It then checks that the balances of the two users are updated correctly after the transfer.

# NftMarketPlace.sol

The **NftMarketPlace** contract is an Ethereum smart contract that enables users to buy and sell Non-Fungible Tokens (NFTs) on a decentralized marketplace. It has the following functionalities:

- Listing of NFTs for sale
- Buying of NFTs listed for sale
- Setting of platform fee
- Retrieving of NFT details

**Contract Details**

- Contract Name: NftMarketPlace
- Solidity Version: >=0.4.22 <0.9.0
- License: MIT

**Dependencies**

- OpenZeppelin: **ERC721URIStorage.sol**, **ReentrancyGuard.sol**, and **Pausable.sol**
- UniswapV3Price.sol
- LiquidityPool.sol
- ERC721.sol

### Contract Variables

**Public Variables**

- **OWNER**: an address variable that stores the address of the contract owner.
- **Platform\_Fee**: a **uint120** variable that stores the fee charged by the platform on all transactions.
- **Id**: a **uint256** variable that is incremented every time a new NFT is listed for sale.
- **LiquidityPoolAddress**: an immutable **MultiTokenLiquidityPool** variable that stores the address of the liquidity pool used for trading.
- **NftPrice**: a mapping that maps a token ID to its listed price.
- **Contract\_Address**: a mapping that maps a creator's address to the contract address.
- **NftDetails**: a mapping that maps a contract address and a token ID to the NFT details.

**Private Variables**

- **NotOwner():** a private function that throws an error if the caller is not the contract owner.
- **NoZeroAddress():** a private function that throws an error if the NFT address is zero.
- **NoZeroPrice():** a private function that throws an error if the NFT price is zero.

### Contract Functions

**constructor(uint120 \_platformFee, address Liqudityaddr)**

This is the contract constructor. It takes in two parameters:

- **\_platformFee**: a **uint120** value that sets the platform fee for all transactions.
- **Liqudityaddr**: an **address** value that sets the address of the liquidity pool.

**onlyOwner()**

This is a modifier that throws an error if the caller is not the contract owner.

**setFee(uint120 \_platformfee)**

This is a function that allows the contract owner to set the platform fee. It takes in one parameter:

- **\_platformfee**: a **uint120** value that sets the new platform fee.

**ListNft(address nftAddress, uint256 \_tokenId, uint256 \_price, uint256 \_royality)**

This is a function that allows a user to list an NFT for sale. It takes in four parameters:

- **nftAddress**: the address of the NFT contract.
- **\_tokenId**: the ID of the NFT to be listed.
- **\_price**: the price at which the NFT is being listed.
- **\_royality**: the percentage of the sale price to be paid to the creator as a royalty fee.

**Buy(address nftAddress, uint256 \_tokenId, address ERC20tokenAddress, uint256 amount)**

This is a function that allows a user to buy an NFT listed for sale. It takes in four parameters:

- **nftAddress**: the address of the NFT contract.
- **\_tokenId**: the ID of the NFT being bought.
- **ERC20tokenAddress:** the address of the ERC20 token to be used for payment.
- **amount:** the amount of ERC20

# NftMarketPlaceTest.js

The **describe** function is used to group related test cases together. In this case, there is only one group of tests, named "nft market place contract testing". The **beforeEach** function is used to set up the environment for each test case. In this case, it deploys the NFT marketplace contract, two ERC20 tokens, one ERC721 token, and a liquidity pool contract.

- The first test case checks if the NFT marketplace contract can list an NFT for sale correctly. It mints an NFT, approves the marketplace contract to sell it on behalf of the user, lists the NFT on the marketplace with a price, and then retrieves the details of the NFT from the marketplace contract to check if the price is set correctly.
- The second test case checks if an NFT can be bought using ERC20 tokens correctly. It mints ERC20 tokens to two different users, approves the liquidity pool contract to spend the tokens on their behalf, deposits the tokens into the liquidity pool, lists an NFT for sale on the marketplace, buys the NFT using ERC20 tokens, and then checks the balances of the users involved in the transaction.

# UniswapV3Price.sol

The **UniswapV3Twap** contract is a Solidity smart contract that calculates the Time-Weighted Average Price (TWAP) of a Uniswap V3 pool for a given time interval. It uses the Uniswap V3 protocol to calculate the price of a token pair based on the amount of one token and the desired output token.

**Contract Variables**

- **token0** - the address of the first token in the token pair
- **token1** - the address of the second token in the token pair
- **pool** - the address of the Uniswap V3 pool contract
- **\_fee** - the fee tiers of the pool in the factory
- **Factory** - the address of the Uniswap V3 factory contract

**Contract Events**

- **LogSetFactory(address indexed factoryAddress)** - emitted when the **SetFactory()** function is called and the address of the factory is updated

**Contract Functions**

- **SetFactory(address \_factory) external** - sets the address of the Uniswap V3 factory contract
- **estimateAmountOut(address tokenIn, address tokenout, uint128 amountIn, uint32 secondsAgo, uint24 \_fee) external view returns (uint amountOut)** - calculates the TWAP for the given time interval by finding the price of tokenIn in terms of tokenOut for amountIn.

**Parameters**

- **tokenIn** - the address of the input token
- **tokenOut** - the address of the output token
- **amountIn** - the amount of tokenIn to be converted to tokenOut
- **secondsAgo** - the time interval in seconds to calculate the TWAP for
- **\_fee** - the fee tiers of the pool in the factory

**Return Value**

**amountOut** - the calculated amount of **tokenOut** for the given **amountIn** input token at the TWAP for the given time interval

**Usage**

To use this contract, you need to provide the address of the Uniswap V3 factory contract and call the **estimateAmountOut()** function with the required parameters. The function returns the calculated amount of output token for the given input token at the TWAP for the given time interval.

Note that the contract only estimates the amount of output token based on the TWAP and does not execute any trades.

# UniswapV3TWAPTest.js

is a JavaScript test file used to test the **UniswapV3Twap** contract. It uses the Chai assertion library and the Hardhat testing framework.

The test suite is then defined using the **describe** function, with the string "UniswapV3Twap" as the description. Within the **describe** block, a beforeEach function is defined that deploys the **UniswapV3Twap** contract and sets the factory address.

The first test case is defined using the **it** function, with the string "**get price**" as the description. Within the test case, the **estimateAmountOut** function is called on the **twap** contract instance, passing in the two token addresses, an input amount of 10^18 (converted based on the decimal values), a time interval of 10 seconds, and the fee. The resulting price is then logged to the console.

Overall, this test file is used to verify that the **UniswapV3Twap** contract can correctly estimate the price of a token pair on Uniswap V3, given certain input parameters.
