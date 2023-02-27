// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "./Interfaces/IERC20.sol";


contract MultiTokenLiquidityPool {
    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => bool) public tokens;

    address public immutable owner;

    constructor() {
        owner = msg.sender;
            }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function addToken(address token) external onlyOwner {
        require(token != address(0), "Invalid token address.");
        tokens[token] = true;
    }

    function removeToken(address token) external onlyOwner {
        require(token != address(0), "Invalid token address.");
        tokens[token] = false;
    }

    function deposit(address token, uint256 amount) external {
        require(tokens[token], "Token not supported.");
        require(amount > 0, "Amount must be greater than zero.");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        balances[msg.sender][token] += amount;
    }

    function withdraw(address token, uint256 amount) external {
        require(balances[msg.sender][token] >= amount, "Insufficient balance.");
        require(amount != 0, "Amount must be greater than zero.");
        IERC20(token).transfer(msg.sender, amount);
        balances[msg.sender][token] -= amount;
    }

    function transfer(address to , address token, uint256 amount) external{
            require(tokens[token], "Token not supported.");
            require(balances[msg.sender][token] >= amount, "Insufficient balance.");
            require(amount != 0, "Amount must be greater than zero.");
            balances[msg.sender][token] -= amount;
            balances[to][token]+=amount;
    }

    function getBalance(address token, address account) external view returns (uint256) {
        return balances[account][token];
    }

    function withdrawAll(address[] calldata tokensList) external {
        for (uint i=0; i<tokensList.length; i++) {
            address token = tokensList[i];
            uint256 amount = balances[msg.sender][token];
            if (amount > 0) {
                IERC20(token).transfer(msg.sender, amount);
                balances[msg.sender][token] = 0;
            }
        }
    }
}
