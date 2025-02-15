// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Marketplace is Ownable{ // Only owner could make changes.
    using Counters for Counters.Counter;
    
    Counters.Counter private _marketItemIds;   // keep a track of marketItems 
    Counters.Counter private _tokensSold;       // No. of items 
    Counters.Counter private _tokensCanceled;    // 


    struct MarketItems{
        uint256 id;
        uint256 amount;
        address payable seller;
        address payable buyer;
        address tokenAddress;
        uint256 price;
        bool sold;
        bool canceled;
    }

    mapping ( uint256 => MarketItems ) public marketItems; 
    mapping(address => uint256[]) public userListings;

    event MarketItemCreated(uint256 id, address indexed seller, uint256 amount, uint256 price);
    event MarketItemSold(uint256 id, address indexed buyer, uint256 amount);
    event MarketItemCanceled(uint256 id, address indexed seller);

    uint256 public listingFee = 0.045 ether; // Fee to list an item
    address payable public treasury; // Address where listing fees are sent

    constructor(address payable _treseaury){
        treasury = _treseaury;
    }

    function sellTokens (address _tokenAddress, uint256 _amount, uint256 _price) external payable{
        require(msg.value > 0, "");
        require(_amount > 0, "");
        require(_price > 0, "");

        IERC20 token = IERC20(_tokenAddress);
        require(token.transferFrom(msg.sender, address(this), _amount), "Transfer failed.");

        _marketItemIds.increment();

        uint256 newItemId = _marketItemIds.current();


        marketItems[newItemId] = MarketItems(
            newItemId,
            _amount,
            payable(msg.sender),
            payable(address(0)),
            _tokenAddress,
            _price,
            false,
            false
        );
        
        userListings[msg.sender].push(newItemId);
        treasury.transfer(msg.value);
        emit MarketItemCreated(newItemId, msg.sender, _amount, _price);
    }


    // buy and cancel buying the fungible token.abi

    function buyToken(uint256 _tokenId) external payable{
        MarketItems storage item = marketItems[_tokenId];  // what's this ?

        require(!item.sold, "");
        require(!item.canceled, "");
        require(msg.value == item.price, "");

        item.sold = true;
        item.buyer = payable(msg.sender);

        IERC20(item.tokenAddress).transfer(msg.sender, item.amount);

        payable(item.seller).transfer(msg.value);

        _tokensSold.increment();
        emit MarketItemSold(_tokenId, msg.sender, item.amount);
    }

    function cancelListing(uint256 itemId) external {
        MarketItems storage item = marketItems[itemId];
        require(msg.sender == item.seller, "Not the seller."); // Only the seller can cancel
        require(!item.sold, "Item already sold."); // Cannot cancel if already sold

        IERC20(item.tokenAddress).transfer(item.seller, item.amount);

        item.canceled = true;

        _tokensCanceled.increment();
        emit MarketItemCanceled(itemId, msg.sender);
    }

    function userListing(address user) external view returns(uint256 [] memory){
        return userListings[user];  // get the market items listed by a user.
    }

}


