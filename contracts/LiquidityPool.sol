// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
import "./Interfaces/IERC20.sol";

contract MultiTokenLiquidityPool {
    // ower address=>token address------->balance
    mapping(address => mapping(address => uint256)) public balances;
    mapping(address => bool) public tokens;

    address public immutable owner;

    event LogDeposite(
        address indexed token,
        address indexed owner,
        uint256 indexed amount
    );
    event LogWithdraw(
        address indexed token,
        address indexed owner,
        uint256 indexed amount
    );
    event LogTransfer(
        address indexed token,
        address indexed from,
        address indexed to,
        uint256 amount
    );

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
        require(
            IERC20(token).balanceOf(msg.sender) >= amount,
            "insufficient amount"
        );
        /// approve token for this liquidity pool contract
        require(IERC20(token).transferFrom(msg.sender, address(this), amount));
        balances[msg.sender][token] += amount;
        emit LogDeposite(token, msg.sender, amount);
    }

    function withdraw(address token, uint256 amount) external {
        require(balances[msg.sender][token] >= amount, "Insufficient balance.");
        require(amount != 0, "Amount must be greater than zero.");
        balances[msg.sender][token] -= amount;
        require(IERC20(token).transfer(msg.sender, amount));
        emit LogWithdraw(token, msg.sender, amount);
    }

    function Transfer(
        address from,
        address to,
        address token,
        uint256 amount
    ) external {
        require(tokens[token], "Token not supported.");
        require(balances[from][token] >= amount, "Insufficient balance.");
        require(amount != 0, "Amount must be greater than zero.");
        balances[from][token] -= amount;
        balances[to][token] += amount;
        emit LogTransfer(token, from, to, amount);
    }

    function getBalance(address account, address token)
        external
        view
        returns (uint256)
    {
        return balances[account][token];
    }

    function withdrawAll(address[] calldata tokensList) external {
        for (uint256 i; i < tokensList.length; ++i) {
            address token = tokensList[i];
            uint256 amount = balances[msg.sender][token];
            if (amount > 0) {
                balances[msg.sender][token] = 0;
                require(IERC20(token).transfer(msg.sender, amount));
            }
        }
    }
}
