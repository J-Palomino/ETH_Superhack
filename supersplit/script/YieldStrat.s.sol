// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {YieldStrat} from "../src/YieldStrat.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract YieldStratScript is Script {
    YieldStrat public yieldStrat;
    IERC20 public usdc;

    function setUp() public {
        // Set the USDC token address, replace with the address on your target network
        // usdc = IERC20(0xA0b86991c6218b36c1d19d4a2e9eb0ce3606eb48); // USDC on Ethereum Mainnet
        usdc = IERC20(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8); // USDC on Sepolia
    }

    function run() public {
        vm.startBroadcast();

        // Deploy the YieldStrat with USDC as the underlying asset
        yieldStrat = new YieldStrat(usdc);

        console.log("Deployed YieldStrat at", address(yieldStrat));

        vm.stopBroadcast();
    }
}
