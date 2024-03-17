// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/BaseHook.sol";

import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import "./IStablepoint.sol"; 



contract Counter is BaseHook {
    using PoolIdLibrary for PoolKey;
    IStablepoint public stablepoint;

    // NOTE: ---------------------------------------------------------
    // state variables should typically be unique to a pool
    // a single hook contract should be able to service multiple pools
    // ---------------------------------------------------------------

    address public constant BURN_CONTRACT = address(0);
    address public constant STBP_CONTRACT = 0x68B1D87F95878fE05B998F19b66F4baba5De1aed;


    mapping(PoolId => uint256 count) public afterAddLiquidityCount;
    mapping(PoolId => uint256 count) public beforeRemoveLiquidityCount;
    mapping(PoolId => uint256 count) public afterRemoveLiquidityCount;

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {

        stablepoint = IStablepoint(STBP_CONTRACT);
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: true,
            beforeRemoveLiquidity: true,
            afterRemoveLiquidity: true,
            beforeSwap: false,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    // -----------------------------------------------
    // NOTE: see IHooks.sol for function documentation
    // -----------------------------------------------


    function afterAddLiquidity(
        address user,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata,
        BalanceDelta delta,
        bytes calldata
    ) external override returns (bytes4) {
        afterAddLiquidityCount[key.toId()]++;

        uint256 amount = calculateAbsolutePointAmount(delta);
        stablepoint.mint(user, amount);

        return BaseHook.afterAddLiquidity.selector;
    }

    function beforeRemoveLiquidity(
        address user,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata
    ) external override returns (bytes4) {
        beforeRemoveLiquidityCount[key.toId()]++;

        uint256 amount = safeInt256ToUint256(params.liquidityDelta);

        // Check if the user has enough Stablepoint tokens.
        require(stablepoint.balanceOf(user) >= amount, "Insufficient tokens to remove liquidity");
        return BaseHook.beforeRemoveLiquidity.selector;
    }

    function afterRemoveLiquidity(
        address user,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata,
        BalanceDelta delta,
        bytes calldata
    ) external override returns (bytes4) {
        afterRemoveLiquidityCount[key.toId()]++;
        uint256 amount = calculateAbsolutePointAmount(delta);
        require(stablepoint.transferFrom(user, BURN_CONTRACT, amount), "Transfer failed: Must approve token transfer before removing liquidity");

        return BaseHook.afterRemoveLiquidity.selector;
    }

    // Simplified function to calculate the total points based on the sum of stablecoins added or removed
    function calculateAbsolutePointAmount(BalanceDelta balanceDelta) private pure returns (uint256) {
        uint256 amount0 = safeInt128ToUint256(balanceDelta.amount0());
        uint256 amount1 = safeInt128ToUint256(balanceDelta.amount1());
        return amount0 + amount1;
    }

    function safeInt128ToUint256(int128 value) private pure returns (uint256) {
        if(value < 0) {
            return uint256(-int256(value)); // Convert negative values to their absolute value then to uint256
        } else {
            return uint256(int256(value)); // Convert positive values directly
        }
    }

    function safeInt256ToUint256(int256 value) private pure returns (uint256) {
        if(value < 0) {
            return uint256(-value); // Convert negative values to their absolute value then to uint256
        } else {
            return uint256(value); // Convert positive values directly
        }
    }

}
