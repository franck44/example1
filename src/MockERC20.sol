// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Minimal mintable ERC-20 for local Foundry and Halmos experiments.
/// @dev Anyone may mint. Do not use this contract in production.
contract MockERC20 {
    error InsufficientBalance();
    error InvalidReceiver();

    string public symbol;
    // uint8 public constant DECIMALS = 18;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    // event Transfer(address indexed from, address indexed to, uint256 value);
    // event Approval(
    //     address indexed owner,
    //     address indexed spender,
    //     uint256 value
    // );

    constructor(string memory symbol_) {
        symbol = symbol_;
    }

    function mint(address to, uint256 amount) external {
        if (to == address(0)) revert InvalidReceiver();

        totalSupply += amount;
        balanceOf[to] += amount;
    }

    function transferTo(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) private {
        if (to == address(0)) revert InvalidReceiver();

        uint256 balance = balanceOf[from];
        if (balance < amount) revert InsufficientBalance();

        balanceOf[from] = balance - amount;
        // unchecked {
        //     balanceOf[from] = balance - amount;
        // }
        balanceOf[to] += amount;
        // emit Transfer(from, to, amount);
    }
}
