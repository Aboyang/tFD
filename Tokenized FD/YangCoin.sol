// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

// Import libraries
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/access/Ownable.sol";

contract YangCoin is ERC20, Ownable {

    // Declare events
    event Mint(address indexed to, uint256 amount);

    constructor() ERC20("YangCoin", "YANG") {}

    // take fiat deposits from user, mint YangCoin to their wallet
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
        emit Mint(to, amount);
    }
}
