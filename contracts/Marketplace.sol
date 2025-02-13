// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";    
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MemeCoinMarketplace {
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokensSold;
    Counters.Counter private _tokensCanceled;
    Counters.Counter private _marketItemIds;

    address payable private owner;
    uint256 private listingFee = 0.045 ether;

    struct MarketItem {
        uint256 marketItemId;
        uint256 amount;  // Use amount instead of tokenId for ERC-20 tokens
        address tokenAddress;
        address payable seller;
        address payable buyer;
        uint256 price;
        bool sold;
        bool canceled;
    }

    mapping(uint256 => MarketItem) public marketItemIdToMarketItem;

    constructor() {
        owner = payable(msg.sender);
    }

    function getListingFees() public view returns (uint256) {
        return listingFee; 
    }

    // List an ERC-20 token on the marketplace
    function createMarketItem(address tokenAddress, uint256 amount, uint256 price) public payable {
        require(msg.value == listingFee, "Must pay listing fee.");
        require(price > 0, "Price must be greater than 0.");
        require(amount > 0, "Amount must be greater than 0.");

        _marketItemIds.increment();
        uint256 marketItemId = _marketItemIds.current();

        // Transfer tokens from seller to contract
        require(IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount), "Transfer failed.");

        marketItemIdToMarketItem[marketItemId] = MarketItem(
            marketItemId,
            amount,
            tokenAddress,
            payable(msg.sender),
            payable(address(0)), 
            price,
            false,
            false
        );
    }

    // Buy a token from the marketplace
    function createMarketForSale(uint256 marketItemId) public payable {
        MarketItem storage item = marketItemIdToMarketItem[marketItemId];

        require(!item.sold, "Item already sold.");
        require(!item.canceled, "Item was canceled.");
        require(msg.value == item.price, "Incorrect price.");

        // Mark item as sold
        item.sold = true;
        item.buyer = payable(msg.sender);

        // Transfer tokens to buyer
        require(IERC20(item.tokenAddress).transfer(msg.sender, item.amount), "Token transfer failed.");

        // Transfer funds to seller
        item.seller.transfer(msg.value);
        
        // Increment sold counter
        _tokensSold.increment();

        // Pay listing fee to contract owner
        owner.transfer(listingFee);
    }

    // Fetch available market items
    function fetchAvailableMarketItems() public view returns (MarketItem[] memory) {
        uint256 totalItems = _marketItemIds.current();
        uint256 soldItems = _tokensSold.current();
        uint256 canceledItems = _tokensCanceled.current();
        uint256 availableItems = totalItems - (soldItems + canceledItems);

        MarketItem[] memory items = new MarketItem[](availableItems);
        uint index = 0;

        for (uint i = 1; i <= totalItems; i++) {
            if (!marketItemIdToMarketItem[i].sold && !marketItemIdToMarketItem[i].canceled) {
                items[index] = marketItemIdToMarketItem[i];
                index++;
            }
        }
        return items;
    }

    // Cancel a listing and return tokens to seller
    function cancelMarketItem(uint256 marketItemId) public {
        MarketItem storage item = marketItemIdToMarketItem[marketItemId];

        require(item.amount > 0, "Market item does not exist.");
        require(item.seller == msg.sender, "You are not the seller.");
        require(!item.sold, "Cannot cancel a sold item.");

        // Transfer tokens back to the seller
        require(IERC20(item.tokenAddress).transfer(item.seller, item.amount), "Token return failed.");

        // Mark item as canceled
        item.canceled = true;

        // Increment canceled counter
        _tokensCanceled.increment();
    }
}
