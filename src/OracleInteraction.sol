// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./OptimisticOracleV3Interface.sol";

contract OracleInteraction {
    OptimisticOracleV3Interface private oracle;
    IERC20 private bondCurrency;
    bytes32 public identifier = "YES_OR_NO_QUERY";
    bytes public ancillaryData;
    uint256 public requestTime;
    bytes32 public assertionId; // Unique identifier for the assertion

    event DataRequested(string question);
    event DataSettled(bool outcome);

    constructor(address _oracleAddress, address _bondCurrency) {
        oracle = OptimisticOracleV3Interface(_oracleAddress);
        bondCurrency = IERC20(_bondCurrency);
    }

    // Request data from UMA's Optimistic Oracle V3
    function requestData(string memory question) external {
        ancillaryData = abi.encodePacked("Q:", question, "Who will win the 2024 US Presidential Election?");
        requestTime = block.timestamp;

        uint256 bondAmount = 1 ether; // Define bond amount based on requirements
        assertionId = oracle.assertTruth(
            ancillaryData,
            msg.sender, // The address of the asserter, can be the caller
            address(this), // Callback recipient is this contract
            address(0), // No custom escalation manager, so we pass zero address
            7200, // Liveness period in seconds (2 hours)
            bondCurrency, // Bond currency for the assertion
            bondAmount, // Amount of the bond
            identifier, // Oracle identifier for UMA to recognize the claim
            bytes32(0) // No domain specified
        );

        emit DataRequested(question);
    }

    // Function to settle the assertion and retrieve the result
    function settleData() external {
        // Settling the assertion
        oracle.settleAssertion(assertionId);

        // Fetch the resolved result of the assertion as a single boolean
        bool outcome = oracle.getAssertionResult(assertionId);
        
        emit DataSettled(outcome);
    }
}
