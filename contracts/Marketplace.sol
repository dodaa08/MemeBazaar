// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";    
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract Marketplace{
    
    using Counters for Counters.Counter;
    Counters.Counter private _tokensSold;
    Counters.Counter private _tokensCanceled;
    Counters.Counter private _marketItemIds;

    address payable private owner;
    uint256 private listingFee = 0.045 ether;

    mapping(uint256 => MarketItem) public marketItemIdToMarketItem;   // map the id to items simply.

    struct MarketItem{
        uint256  marketItemId;
        uint256 tokenId;
        address itemAddress;
        address payable seller;
        address payable buyer;
        uint256 price;
        bool sold;
        bool canceled;
    }
    constructor(){
        owner = payable(msg.sender);
    }

    function getListingfees() public view returns(uint){
        return listingFee; 
    }


    // list the item on the market.
    function createMarketItem(address tokenAddress, uint256 tokenId, uint256 price) public payable {
        require(msg.value == listingFee, "Amount of the Token must be something/greater than 0.");
        require(price > 0, "Price of the Token must be something/greater than 0.");    

        _marketItemIds.increment();

        marketItemIdToMarketItem[_marketItemIds.current()] = MarketItem(
            _marketItemIds.current(),
            tokenId,
            tokenAddress,
            payable(msg.sender),
            payable(address(0)),   // u gotta specify weather something is payable or not.
            price,
            false,
            false
        );
    }




    // create a market for sale 
    function createMarketforsale(address coinAddress, uint256 tokenId) public payable{


        // add token and price 
        uint256 price = marketItemIdToMarketItem[_marketItemIds.current()].price;
        uint256 tokenId = marketItemIdToMarketItem[_marketItemIds.current()].tokenId;

        require(msg.value == price, "Please submit the asking price in order to sell");
        marketItemIdToMarketItem[_marketItemIds.current()].sold = true;

        marketItemIdToMarketItem[_marketItemIds.current()].seller.transfer(msg.value);
        IERC20(coinAddress).transferFrom(address(this), msg.sender, tokenId);


        _tokensSold.increment();
    
        payable(owner).transfer(listingFee);
        
    }

    // Find the Available Market items.

    function fetchAvailableMarketItems() public view returns(MarketItem [] memory){
        uint256 itemcount = _marketItemIds.current();
        uint256 soldItemcount = _tokensSold.current();
        uint256 itemCanceledcount = _tokensCanceled.current();

        uint256 availItems = itemcount > (soldItemcount + itemCanceledcount) ? itemcount - soldItemcount - itemCanceledcount : 0;

        MarketItem [] memory marketItems = new MarketItem[](availItems);
        

        // logic to put the items in the array;
        uint index = 0;
        for(uint i = 0; i<itemcount;i++){
            if(!marketItemIdToMarketItem[i].sold && !marketItemIdToMarketItem[i].canceled){
                marketItems[index]  = marketItemIdToMarketItem[i]; // put the available market items in the array.
                index++;
            }
        }


        return marketItems;
    }




}
