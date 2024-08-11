// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IYieldStrategy {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function totalAssets() external view returns (uint256);
}
