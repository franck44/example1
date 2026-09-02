// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MockERC20} from "./MockERC20.sol";

contract SimplifiedBalancerV2 {
    // token exchange rates
    uint8 public token0Rate;
    uint8 public token1Rate;

    // Token contracts
    MockERC20 public immutable TOKEN0;
    MockERC20 public immutable TOKEN1;

    // Reverts
    error TransferFailed();

    /// Initialize pool with two tokens and their rates
    constructor(
        MockERC20 token0_,
        MockERC20 token1_,
        uint8 rate0_,
        uint8 rate1_
    ) {
        TOKEN0 = token0_;
        TOKEN1 = token1_;

        token0Rate = rate0_;
        token1Rate = rate1_;
    }

    // Swap token0 to token1 by specifying the amount of token1 wanted.
    function swapExactOutToToken1(
        uint256 amountOutToken1
    ) external returns (uint256) {
        /*
         * Vulnerability:
         *
         * The user asks for an exact amount of TOKEN1.
         * The pool calculates how much TOKEN0 they must pay.
         *
         * Division rounds down, so the user may underpay.
         */
        uint256 amountInToken0 = (amountOutToken1 * token1Rate) / token0Rate;

        // tranfer token0 from sender to pool
        bool res1 = TOKEN0.transferFrom(
            msg.sender,
            address(this),
            amountInToken0
        );
        if (!res1) {
            revert TransferFailed();
        }

        // transfer token1 from pool to sender
        bool res2 = TOKEN1.transferTo(msg.sender, amountOutToken1);
        if (!res2) {
            revert TransferFailed();
        }

        return amountInToken0;
    }
}
