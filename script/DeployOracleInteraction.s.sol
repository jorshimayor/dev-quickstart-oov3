// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../src/OracleInteraction.sol";

contract DeployOracleInteraction is Script {
    function run() external {
        // Load environment variables
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions with the private key
        vm.startBroadcast(privateKey);

        // Deploy the OracleInteraction contract
        address oracleAddress = 0xFd9e2642a170aDD10F53Ee14a93FcF2F31924944; // Replace with UMA Optimistic Oracle V3 contract address
        address bondCurrency = 0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43 ; // Replace with the bond currency ERC20 token address(Sepolia is used here)
        OracleInteraction oracleInteraction = new OracleInteraction(oracleAddress, bondCurrency);

        // End broadcasting transactions
        vm.stopBroadcast();

        // Log the contract address
        console.log("OracleInteraction deployed at:", address(oracleInteraction));
    }
}
