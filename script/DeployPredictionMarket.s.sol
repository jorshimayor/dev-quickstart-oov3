// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "forge-std/Script.sol";
import "../src/PredictionMarket.sol";

contract DeployPredictionMarket is Script {
    function run() external {
        // Load environment variables
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions with the private key
        vm.startBroadcast(privateKey);

        // Deploy the PredictionMarket contract
        address oracleRelayer = 0xEEE5BEC08C3fd98535183c247931FFC439778A7C;
        uint256 bettingDuration = 1 days; // Set the betting duration as required
        PredictionMarket predictionMarket = new PredictionMarket(bettingDuration, oracleRelayer);

        // End broadcasting transactions
        vm.stopBroadcast();

        // Log the contract address
        console.log("PredictionMarket deployed at:", address(predictionMarket));
    }
}
