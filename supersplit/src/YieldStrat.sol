// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IYieldStrategy.sol";

contract YieldStrat is IYieldStrategy {
    IERC20 public immutable asset;

    // Track the total assets under management
    uint256 private _totalAssets;

    constructor(IERC20 asset_) {
        asset = asset_;
    }

    // Deposit assets into the strategy
    function deposit(uint256 amount) external override {
        require(amount > 0, "Amount must be greater than zero");

        // Transfer the tokens from the caller to this contract
        asset.transferFrom(msg.sender, address(this), amount);

        // Update the total assets under management
        _totalAssets += amount;
    }

    // Withdraw assets from the strategy
    function withdraw(uint256 amount) external override {
        require(amount > 0, "Amount must be greater than zero");
        require(amount <= _totalAssets, "Not enough assets");

        // Transfer the tokens from this contract to the caller
        asset.transfer(msg.sender, amount);

        // Update the total assets under management
        _totalAssets -= amount;
    }

    // Return the total assets under management
    function totalAssets() external view override returns (uint256) {
        return _totalAssets;
    }
}
