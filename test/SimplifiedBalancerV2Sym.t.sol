// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {SymTest} from "halmos-cheatcodes/SymTest.sol";

import {MockERC20} from "../src/MockERC20.sol";
import {SimplifiedBalancerV2} from "../src/SimplifiedBalancerV2.sol";

/// @title Symbolic security tests for SimplifiedBalancerV2
/// @notice Uses Halmos to search for profitable exact-out swaps caused by input-amount rounding.
/// @dev Each execution deploys a pool with symbolic reserves and positive token valuation rates,
/// then values the attacker's balances in a common unit before and after a swap. The checks bound
/// the gain that an attacker with `INIT_ATTACKER_CAP` units of token0 can obtain from rounding.
contract SimplifiedBalancerV2SymTest is SymTest, Test {
    // Token0 and Token1 are ERC20 contracts
    MockERC20 token0;
    MockERC20 token1;

    // pool has two tokens with their own rate
    uint8 token0Rate;
    uint8 token1Rate;

    // The attacker address
    address constant ATTACKER = address(0xCAFE);

    uint256 constant INIT_ATTACKER_CAP = 2000;

    //  The pool is a simplified version of BalancerV2
    SimplifiedBalancerV2 pool;

    /// SetUp for symbolic testing with Halmos
    function setUp() public {
        token0 = new MockERC20("T0");
        token1 = new MockERC20("T1");
    }

    // forge-lint: disable-next-line(mixed-case-function)
    /// @notice Checks that an exact-out swap cannot yield more than x units of value.
    /// @dev Uses symbolic output amounts, pool liquidity, and token valuation rates.
    /// @custom:halmos --solver-timeout-assertion 5m --solver bitwuzla-abs
    function check_ExactOutRounding(
        uint32 amountOut,
        uint32 initLiq0,
        uint32 initLiq1,
        uint8 initRate0,
        uint8 initRate1
    ) public {
        // Constraints (symbolic) on initial values
        vm.assume(amountOut > 0);
        vm.assume(amountOut <= INIT_ATTACKER_CAP);
        // Liquidity
        vm.assume(initLiq0 > 0);
        vm.assume(initLiq1 > 0);
        // exchange rates
        vm.assume(initRate0 > 0);
        vm.assume(initRate1 > 0);
        vm.assume(initRate0 <= 4);
        vm.assume(initRate1 <= 10);

        // Store the token rates locally
        token0Rate = initRate0;
        token1Rate = initRate1;

        // create the pool
        pool = new SimplifiedBalancerV2(token0, token1, initRate0, initRate1);

        // Mint initial pool liquidity (symbolic initial state)
        token0.mint(address(pool), initLiq0);
        token1.mint(address(pool), initLiq1);

        // Mint Attacker tokens
        token0.mint(ATTACKER, INIT_ATTACKER_CAP);

        // Start test
        uint256 valueBefore = attackerValue();
        vm.startPrank(ATTACKER);
        uint256 amountIn = pool.swapExactOutToToken1(amountOut);
        vm.stopPrank();
        uint256 valueAfter = attackerValue();

        // Check that valueAfter <= valueBefore + x
        // If x = 0, no profit can be made. Otherwise a bounded profit can be made
        // assertLe(
        //     100 * valueAfter,
        //     109 * valueBefore,
        //     "attacker did make a profit"
        // );

        assertLe(valueAfter, valueBefore + 3, "attacker did make a profit");
    }

    /// @notice Returns the attacker's total value in weighted unit.
    /// @dev Each token balance is weighted by its symbolic exchange rate.
    function attackerValue() internal view returns (uint256) {
        uint256 token0Value = token0.balanceOf(ATTACKER) * token0Rate;
        uint256 token1Value = token1.balanceOf(ATTACKER) * token1Rate;
        return token0Value + token1Value;
    }
}
