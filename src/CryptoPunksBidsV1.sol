// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/*

CryptoPunksBids.sol

Written by: mousedev.eth

Concept by: mousedev.eth & kilo

*/

import "forge-std/console.sol";
import "./interfaces/ICryptoPunksMarket.sol";
import "./interfaces/ICryptoPunksData.sol";

struct GlobalBid {
    //128 bits
    uint128 bidWei;

    //128 bits
    uint128 settlementWei;

    //160 bits
    address bidder;

    //160 bits optional receiver (if u want to send to cold wallet.)
    address receiver;
}

contract CryptoPunksBidsV1 {
    mapping(uint256 => GlobalBid) public globalBids;

    bytes32 public signature = 0x45f542cfc742a52831b47ba8656d214083b07269bfdb7cbc455a8fbca649c19a;

    uint256 public currentBidId = 1;

    address public cryptoPunksAddress;

    event BidPlaced(uint256 _thisBidId,uint256 _bidWei);
    event BidRemoved(uint256 _bidId);
    event BidAdjusted(uint256 _bidId, uint256 _newBidWei);
    event BidSettlementAdjusted(uint256 _bidId, uint256 _newBidSettlementWei);

    constructor(address _cryptoPunksAddress)
    {
        cryptoPunksAddress = _cryptoPunksAddress;
    }

    /**
     * @dev Places a global or trait bid.
     * @param _bidWei wei to bid.
     * @param _settlementWei wei as a bribe to a bot for settlement.
     */
    function placeBid(
        uint128 _bidWei,
        uint128 _settlementWei,
        address _receiver
    ) public payable returns(uint256){
        //Require they sent exact ether with tx.
        require(
            msg.value == _bidWei + _settlementWei,
            "Ether sent did not match ether in bid"
        );

        uint256 _thisBidId = currentBidId;

        globalBids[_thisBidId] = GlobalBid(
            _bidWei,
            _settlementWei,
            msg.sender,
            _receiver
        );

        currentBidId++;

        emit BidPlaced( _thisBidId, _bidWei);

        return _thisBidId;
    }

    /**
     * @dev Cancels a bid.
     * @param _bidId Bid to cancel.
     */
    function cancelBid(uint256 _bidId) public {
        GlobalBid memory _globalBid = globalBids[_bidId];

        //Require they made this bid.
        require(_globalBid.bidder == msg.sender, "You did not make this bid!");

        //Remove struct from storage.
        delete globalBids[_bidId];

        //Send eth back to bidder
        (bool succ1, ) = payable(msg.sender).call{value: _globalBid.bidWei + _globalBid.settlementWei}("");
        require(succ1, "transfer failed");

        emit BidRemoved( _bidId);
    }

    function adjustBidPrice(uint256 _bidId, uint128 _weiToAdjust, bool _direction) public payable {
        GlobalBid memory _globalBid = globalBids[_bidId];

        //Require they made this bid.
        require(_globalBid.bidder == msg.sender, "You did not make this bid!");

        if(_direction){
            //increase bid
            require(msg.value >= _weiToAdjust, "Did not send enough wei for adjustment");

            uint128 _oldBidWei = globalBids[_bidId].bidWei;

            globalBids[_bidId].bidWei = _oldBidWei + _weiToAdjust;

            emit BidAdjusted(_bidId, _oldBidWei + _weiToAdjust);
        } else {
            //reduce bid
            require(_globalBid.bidWei >= _weiToAdjust, "Adjustment is higher than current bid");

            uint128 _oldBidWei = globalBids[_bidId].bidWei;

            globalBids[_bidId].bidWei = _oldBidWei - _weiToAdjust;

            //Send settlement incentive to settler
            (bool succ1, ) = payable(msg.sender).call{
                value: _weiToAdjust
            }("");
            require(succ1, "transfer failed");

            emit BidAdjusted(_bidId, _oldBidWei - _weiToAdjust);
        }
    }

    function adjustBidSettlementPrice(uint256 _bidId, uint128 _weiToAdjust, bool _direction) public payable {
        GlobalBid memory _globalBid = globalBids[_bidId];

        //Require they made this bid.
        require(_globalBid.bidder == msg.sender, "You did not make this bid!");

        if(_direction){
            //increase bid
            require(msg.value >= _weiToAdjust, "Did not send enough wei for adjustment");

            uint128 _oldSettlementWei = globalBids[_bidId].settlementWei;

            globalBids[_bidId].settlementWei = _oldSettlementWei + _weiToAdjust;

            emit BidAdjusted(_bidId, _oldSettlementWei + _weiToAdjust);
        } else {
            //reduce bid
            require(_globalBid.settlementWei >= _weiToAdjust, "Adjustment is higher than current bid");

            uint128 _oldSettlementWei = globalBids[_bidId].settlementWei;

            globalBids[_bidId].settlementWei = _oldSettlementWei - _weiToAdjust;

            //Send settlement incentive to settler
            (bool succ1, ) = payable(msg.sender).call{
                value: _weiToAdjust
            }("");
            require(succ1, "transfer failed");

            emit BidSettlementAdjusted(_bidId, _oldSettlementWei - _weiToAdjust);
        }
    }


    function acceptBid(uint256 _bidId, uint16 _punkId) public {
        //Pull this bid into memory
        GlobalBid memory _globalBid = globalBids[_bidId];

        require(globalBids[_bidId].bidder != address(0x0), "Bid not active!");

        delete globalBids[_bidId];

        //Pull the offer into memory
        Offer memory _offer = ICryptoPunksMarket(cryptoPunksAddress)
            .punksOfferedForSale(_punkId);

        //Require the bid is greater or equal to the offer
        //If you bid 80e, a 70e offer is valid for matching.
        require(_offer.minValue <= _globalBid.bidWei, "Offer not valid.");

        //Buy the punk from the marketplace
        //Costs approx: 87085 gas
        ICryptoPunksMarket(cryptoPunksAddress).buyPunk{value: _offer.minValue}(
            _punkId
        );

        //Send the punk to the bidder
        //Costs approx: 10522 gas
        ICryptoPunksMarket(cryptoPunksAddress).transferPunk(
            _globalBid.receiver == address(0x0) ? _globalBid.bidder: _globalBid.receiver,
            _punkId
        );

        //Settle ETH details
        //Costs approx: 20517 gas (with settlement and excess, excess is likely.)

        //Send settlement incentive to settler
        (bool succ1, ) = payable(msg.sender).call{
            value: _globalBid.settlementWei
        }("");
        require(succ1, "settlement transfer failed");

        //Send excess back to bidder
        if (_globalBid.bidWei > _offer.minValue) {
            (bool succ2, ) = payable(_globalBid.bidder).call{
                value: _globalBid.bidWei - _offer.minValue
            }("");
            require(succ2, "bidder excess transfer failed");
        }
    }
}
