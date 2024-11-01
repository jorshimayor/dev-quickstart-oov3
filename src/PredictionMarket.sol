// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PredictionMarket {
    address public owner;
    address public oracleRelayer;
    uint public deadline;
    bool public marketResolved;
    bool public outcome;

    mapping(address => uint) public betsOnYes;
    mapping(address => uint) public betsOnNo;
    uint public totalBetsOnYes;
    uint public totalBetsOnNo;

    // Events
    event RequestOracleData(uint256 timestamp, string question); 
    event MarketResolved(bool outcome);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    modifier onlyRelayer() {
        require(msg.sender == oracleRelayer, "Only relayer can call");
        _;
    }

    modifier beforeDeadline() {
        require(block.timestamp < deadline, "Betting period over");
        _;
    }

    modifier afterDeadline() {
        require(block.timestamp >= deadline, "Betting period ongoing");
        _;
    }

    constructor(uint _bettingDuration, address _oracleRelayer) {
        owner = msg.sender;
        deadline = block.timestamp + _bettingDuration;
        oracleRelayer = _oracleRelayer;
    }

    // Allow users to bet "Yes"
    function betYes() external payable beforeDeadline {
        require(msg.value > 0, "Bet amount must be greater than zero");
        betsOnYes[msg.sender] += msg.value;
        totalBetsOnYes += msg.value;
    }

    // Allow users to bet "No"
    function betNo() external payable beforeDeadline {
        require(msg.value > 0, "Bet amount must be greater than zero");
        betsOnNo[msg.sender] += msg.value;
        totalBetsOnNo += msg.value;
    }

    // Request data from the Oracle
    function requestMarketData(string memory question) external onlyOwner afterDeadline {
        emit RequestOracleData(block.timestamp, question);
    }

    // Called by the relay to resolve the market
    function resolveMarket(bool _outcome) external onlyRelayer {
        require(!marketResolved, "Market already resolved");
        outcome = _outcome;
        marketResolved = true;
        emit MarketResolved(outcome);
    }

    // Users claim winnings based on the outcome
    function claimWinnings() external afterDeadline {
        require(marketResolved, "Market not resolved");
        uint winnings;

        if (outcome) {
            require(betsOnYes[msg.sender] > 0, "No winnings to claim");
            winnings = (betsOnYes[msg.sender] * address(this).balance) / totalBetsOnYes;
            betsOnYes[msg.sender] = 0;
        } else {
            require(betsOnNo[msg.sender] > 0, "No winnings to claim");
            winnings = (betsOnNo[msg.sender] * address(this).balance) / totalBetsOnNo;
            betsOnNo[msg.sender] = 0;
        }

        payable(msg.sender).transfer(winnings);
    }

    // Withdraw unclaimed funds
    function withdrawUnclaimedFunds() external onlyOwner {
        require(marketResolved, "Market must be resolved before withdrawing");
        payable(owner).transfer(address(this).balance);
    }
}