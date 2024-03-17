// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title IStablepoint Interface
 * @dev Interface for interacting with the Stablepoint ERC20 token.
 */
interface IStablepoint {
    /**
     * @dev Mints `amount` tokens and assigns them to `to`, increasing
     * the total supply.
     *
     * Requirements:
     * - the caller must have the MINTER_ROLE.
     *
     * @param to The address to mint tokens to.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) external;

    /**
     * @dev Returns the amount of tokens owned by `account`.
     *
     * @param account The address of the account to check.
     * @return The amount of tokens owned by the account.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     *
     * @param from The address to transfer tokens from.
     * @param to The address to transfer tokens to.
     * @param amount The amount of tokens to transfer.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}