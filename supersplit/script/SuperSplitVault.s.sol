// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SuperSplitVault} from "../src/SuperSplitVault.sol";
import {IYieldStrategy} from "../src/IYieldStrategy.sol";

contract SuperSplitVaultScript is Script {
    SuperSplitVault public vault;
    IERC20 public asset; // Reference to the ERC20 token you are using
    IYieldStrategy public yieldStrategy; // Reference to your yield strategy contract

    function setUp() public {
        // Initialize your token and yield strategy addresses here
        asset = IERC20(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8); // Replace with your actual ERC20 token address
        yieldStrategy = IYieldStrategy(0x5cB675e6e9e947A1c40b3F83b673c6A8f803f3B7); // Replace with your yield strategy contract address
    }

    function run() public {
        vm.startBroadcast();

        vault = new SuperSplitVault(
            "SuperSplitVault Shares", // Name of the vault token
            "SSVS",                   // Symbol of the vault token
            asset,                    // The ERC20 token used by the vault
            yieldStrategy             // The yield strategy to be used by the vault
        );

        console.log("Deployed SuperSplitVault at", address(vault));

        vm.stopBroadcast();
    }
}

// forge verify-contract 0x25eb8ec026c80caa09E31183b8EBc18Ea52B26d9 SuperSplitVault --etherscan-api-key $TENDERLY_ACCESS_KEY --verifier-url $TENDERLY_VIRTUAL_TESTNET_RPC/verify/etherscan
