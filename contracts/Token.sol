// SPDX-License-Identifier: MIT
pragma solidity >=0.8.00 <0.9.0;

import "./customLib.sol";

contract Token {
    address private owner;
    uint256 public contractBalance = 0;
    uint256 public circulatingTokens = 0;

    mapping(address => uint256) private balances;
    mapping(address => uint256) private liquidityProviders;
    uint256 private numberOfProviders = 0;
    uint256 private totalLiquidity = 0;
    uint256 private rewardsPool = 0;

    uint256 public tokenPrice = 10;

    event Purchase(address indexed buyer, uint256 amount);
    event Sell(address indexed seller, uint256 amount);
    event Price(uint256 price);
    event Transfer(
        address indexed sender,
        address indexed receiver,
        uint256 amount
    );

    constructor() payable {
        require(
            msg.value == 100,
            "As the contract owner you are required to provide 100 wei liquidity"
        );
        owner = msg.sender;
        provideLiquidity(owner, msg.value);
    }

    function buyToken(uint256 amount) public payable returns (bool) {
        require(
            msg.value == amount * tokenPrice,
            "Your funds are not sufficient"
        );
        require(
            amount % 10 == 0,
            "The purchased quantity should be multiple of 10!"
        );
        circulatingTokens += amount;
        contractBalance += amount * tokenPrice;
        balances[msg.sender] += (amount * 90) / 100;
        rewardsPool += (amount * 10) / 100;
        emit Purchase(msg.sender, amount);
        return true;
    }

    function transfer(address recipient, uint256 amount) public returns (bool) {
        require(balances[msg.sender] >= amount, "Not enough balance");
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function sellToken(uint256 amount) public returns (bool) {
        require(amount >= 1, "Provide positive amount of tokens!");
        require(amount <= balances[msg.sender], "Not enough balance!s");
        require(amount > 0, "Not enough balance!");
        circulatingTokens -= amount;
        balances[msg.sender] -= amount;
        contractBalance -= amount * tokenPrice;
        bool success = customLib.customSend(amount * tokenPrice, msg.sender);
        require(success, "Transfer failed!");
        emit Sell(msg.sender, amount);
        return true;
    }

    function changePrice(uint256 price) public returns (bool) {
        require(
            msg.sender == owner,
            "This function is restricted to the contract's owner"
        );
        require(
            contractBalance >= (circulatingTokens * price),
            "Not enough liquidity"
        );

        tokenPrice = price;
        emit Price(price);
        return true;
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function provideLiquidity(address provider, uint256 amount) internal {
        liquidityProviders[provider] += amount;
        totalLiquidity += amount;
        contractBalance += amount;
        numberOfProviders += 1;
    }

    function getReward() internal {
        require(
            liquidityProviders[msg.sender] >= 100,
            "You are not a liquidity provider"
        );

        require(
            rewardsPool % numberOfProviders == 0,
            "You can not receive rewards now (unfair division)"
        );

        uint256 allowance = (liquidityProviders[msg.sender] / totalLiquidity) *
            100;
        balances[msg.sender] += (rewardsPool * allowance) / 100;
        rewardsPool -= (rewardsPool * allowance) / 100;
    }

    fallback() external payable {
        if (msg.value > 0) {
            provideLiquidity(msg.sender, msg.value);
        } else {
            getReward();
        }
    }
}
