// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Treasury is Ownable {
    receive() external payable {}

    function withdrawETH(address payable recipient, uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Insufficient balance.");
        recipient.transfer(amount);
    }

    function withdrawTokens(address token, address recipient, uint256 amount) external onlyOwner {
        require(IERC20(token).transfer(recipient, amount), "Token transfer failed.");
    }
}
