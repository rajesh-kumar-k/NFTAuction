// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
interface IERC721 {
    function transfer(address, uint256) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;
}
contract Bidding {
    address payable public seller;
    bool public started;
    bool public ended;
    IERC721 public nft;
    uint256 public nftId;
    struct info{
        address bidder;
        uint bidderprice;
    }
    info[] Bids;
    constructor() public {
        seller = payable(msg.sender);
        Bids.push(info(0x0000000000000000000000000000000000000000 , 0));
        

    }
    function start(IERC721 _nft,uint256 _nftId) external {
        require(!started, "Bidding was Already started!");
        started = true;
        nft = _nft;
        nftId = _nftId;
        nft.transferFrom(msg.sender, address(this), nftId);
        
    }
    function enterbid(uint _bidderprice) public{
        require(started, "Bidding is not yet started.");
        uint lastentry = Bids.length - 1;
        require(_bidderprice > Bids[lastentry].bidderprice,"Price is not sufficient to enter the Bid");
        Bids.push(info(msg.sender,_bidderprice));
    }
    function end() external {
        require(started, "You need to start first!");
        require(!ended, "Auction already ended!");
    }
    
    function bidresult() public payable returns(address,uint) {
        uint lastentry = Bids.length-1;
        (address highestbidder,uint highestbidamount) = (Bids[lastentry].bidder,Bids[lastentry].bidderprice);
        if (highestbidder != address(0)) {
            nft.transfer(highestbidder, nftId);
            (bool sent, bytes memory data) = seller.call{value: highestbidamount}("");
            require(sent, "Could not pay seller!");
        } else {
            nft.transfer(seller, nftId);
        }
        return (highestbidder,highestbidamount);
    }
}
