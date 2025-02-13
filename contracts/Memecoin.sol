// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MemeCoin is ERC20, Ownable { // ownable here will restrict the user from only deployer to mint mint new tokens 
    uint256 private initial_supply = 1_000_000 * 10**18 ; 

    constructor() ERC20("MemeCoin", "Meme"){
        _mint(msg.sender, initial_supply);
    }

    function Mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
    
    function Burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}

