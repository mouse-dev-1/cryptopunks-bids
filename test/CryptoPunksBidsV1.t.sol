// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ICryptoPunksMarket} from "../src/interfaces/ICryptoPunksMarket.sol";
import {CryptoPunksBidsV1} from "../src/CryptoPunksBidsV1.sol";

contract TestCryptoPunksBidsV1 is Test {
    
    address deployment = deployCode("CryptoPunksMarket.sol");

    ICryptoPunksMarket internal _CryptoPunksMarket;
    CryptoPunksBidsV1 internal _CryptoPunksBidsV1;


    //For receiving ether.
    fallback() external payable{}

    function setUp() public {

        _CryptoPunksMarket = ICryptoPunksMarket(
            deployment
        );

        _CryptoPunksMarket.allInitialOwnersAssigned();

        //Get sum punks.
        _CryptoPunksMarket.getPunk(1);
        _CryptoPunksMarket.getPunk(20);
        _CryptoPunksMarket.getPunk(1045);
        _CryptoPunksMarket.getPunk(6000);

        _CryptoPunksBidsV1 = new CryptoPunksBidsV1(address(_CryptoPunksMarket));
    }


    function testPlacingAndAcceptingBid() public {
        //Offer punk 1 for 100 ether;
        _CryptoPunksMarket.offerPunkForSale(1, 100 ether);

        //Place floor bid for 110 ether;
        uint256 _bidId = _CryptoPunksBidsV1.placeBid{value: 110.01 ether}(110 ether, 0.01 ether, address(0x0));

        //Anyone can call this function.
        _CryptoPunksBidsV1.acceptBid(_bidId, 1);
    }

    function testRevertPlacingAndAcceptingBid() public {
        //Offer punk 1 for 100 ether;
        _CryptoPunksMarket.offerPunkForSale(1, 100 ether);

        //Place floor bid for 90 ether;
        uint256 _bidId = _CryptoPunksBidsV1.placeBid{value: 90.01 ether}(90 ether, 0.01 ether, address(0x0));

        vm.expectRevert("Offer not valid.");

        //Anyone can call this function.
        _CryptoPunksBidsV1.acceptBid(_bidId, 1);
    }

    function testPlacingAndAdjustingBid() public {
        //Offer punk 1 for 100 ether;
        _CryptoPunksMarket.offerPunkForSale(1, 95 ether);

        //Place floor bid for 90 ether;
        uint256 _bidId = _CryptoPunksBidsV1.placeBid{value: 90.01 ether}(90 ether, 0.01 ether, address(0x0));

        (uint128 _bidWeiBefore, uint128 _settlementWeiBefore,,) = _CryptoPunksBidsV1.globalBids(_bidId);
        assertEq(_bidWeiBefore, 90 ether);
        assertEq(_settlementWeiBefore, 0.01 ether);

        //Increase by 5
        _CryptoPunksBidsV1.adjustBidPrice{value: 5 ether}(_bidId, 5 ether, true);

        //Increase by 0.02 settlement
        _CryptoPunksBidsV1.adjustBidSettlementPrice{value: 0.02 ether}(_bidId, 0.02 ether, true);

        (uint128 _bidWeiAfter, uint128 _settlementWeiAfter,,) = _CryptoPunksBidsV1.globalBids(_bidId);
        assertEq(_bidWeiAfter, 95 ether);
        assertEq(_settlementWeiAfter, 0.03 ether);

        //Anyone can call this function.
        _CryptoPunksBidsV1.acceptBid(_bidId, 1);
    }
}
