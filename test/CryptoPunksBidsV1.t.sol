// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

import {ICryptoPunksMarket} from "../src/V1/interfaces/ICryptoPunksMarket.sol";
import {CryptoPunksBidsV1} from "../src/V1/CryptoPunksBidsV1.sol";

contract TestCryptoPunksBidsV1 is Test {
    
    address deployment = deployCode("CryptoPunksMarket.sol");

    ICryptoPunksMarket internal _CryptoPunksMarket;
    CryptoPunksBidsV1 internal _CryptoPunksBidsV1;

    uint16[] _emptyPunkArray = _emptyPunkArray;

    uint16[] _singlePunkArray = new uint16[](1);

    uint16[] _multiPunkArray = new uint16[](4);

    //For receiving ether.
    fallback() external payable {}

    //For receiving ether.
    receive() external payable {}
    
    error EtherSentNotEqualToEtherInBid();
    error MsgSenderNotBidder();
    error NotEnoughWeiSentForPositiveAdjustment();
    error NegativeAdjustmentHigherThanCurrentBid();
    error ETHTransferFailed();
    error BidNotActive();
    error OfferNotValid();
    error PunkNotFoundInArray();

    function setUp() public {

        _CryptoPunksMarket = ICryptoPunksMarket(
            deployment
        );

        _CryptoPunksMarket.allInitialOwnersAssigned();

        //Get sum punks.
        _CryptoPunksMarket.getPunk(1);
        _CryptoPunksMarket.getPunk(20);
        _CryptoPunksMarket.getPunk(123);
        _CryptoPunksMarket.getPunk(1045);
        _CryptoPunksMarket.getPunk(6000);
        _CryptoPunksMarket.getPunk(6010);

        _singlePunkArray[0] = 20;

        _multiPunkArray[0] = 1045;
        _multiPunkArray[1] = 6000;
        _multiPunkArray[2] = 6010;

        _CryptoPunksBidsV1 = new CryptoPunksBidsV1(address(_CryptoPunksMarket));
    }


    function testPlacingAndAcceptingFloorBid() public {
        //Offer punk 1 for 100 ether;
        _CryptoPunksMarket.offerPunkForSale(1, 100 ether);

        //Place floor bid for 110 ether;
        uint256 _bidId = _CryptoPunksBidsV1.placeBid{value: 110.01 ether}(110 ether, 0.01 ether, address(0x0), _emptyPunkArray);

        //Anyone can call this function.
        _CryptoPunksBidsV1.acceptBid(_bidId, 1);
    }

    function testPlacingAndAcceptingPunkSpecificBid() public {
        //Offer punk 1 for 100 ether;
        _CryptoPunksMarket.offerPunkForSale(20, 100 ether);

        //Place floor bid for 110 ether;
        uint256 _bidId = _CryptoPunksBidsV1.placeBid{value: 110.01 ether}(110 ether, 0.01 ether, address(0x0), _singlePunkArray);

        //Anyone can call this function.
        _CryptoPunksBidsV1.acceptBid(_bidId, 20);
    }

    function testPlacingAndAcceptingManyPunkBid() public {
        //Offer punk 1 for 100 ether;
        _CryptoPunksMarket.offerPunkForSale(6000, 100 ether);

        //Place floor bid for 110 ether;
        uint256 _bidId = _CryptoPunksBidsV1.placeBid{value: 110.01 ether}(110 ether, 0.01 ether, address(0x0), _multiPunkArray);

        //Anyone can call this function.
        _CryptoPunksBidsV1.acceptBid(_bidId, 6000);

        vm.expectRevert(BidNotActive.selector);

        //Anyone can call this function.
        _CryptoPunksBidsV1.acceptBid(_bidId, 6010);
    }

    function testRevertPlacingAndAcceptingPunkSpecificBid() public {
        //Offer punk 1 for 100 ether;
        _CryptoPunksMarket.offerPunkForSale(1, 100 ether);

        //Place floor bid for 110 ether;
        uint256 _bidId = _CryptoPunksBidsV1.placeBid{value: 110.01 ether}(110 ether, 0.01 ether, address(0x0), _singlePunkArray);

        vm.expectRevert(PunkNotFoundInArray.selector);

        //Anyone can call this function.
        _CryptoPunksBidsV1.acceptBid(_bidId, 1);
    }


    function testRevertPlacingAndAcceptingFloorBid() public {
        //Offer punk 1 for 100 ether;
        _CryptoPunksMarket.offerPunkForSale(1, 100 ether);

        //Place floor bid for 90 ether;
        uint256 _bidId = _CryptoPunksBidsV1.placeBid{value: 90.01 ether}(90 ether, 0.01 ether, address(0x0), _emptyPunkArray);

        vm.expectRevert(OfferNotValid.selector);

        //Anyone can call this function.
        _CryptoPunksBidsV1.acceptBid(_bidId, 1);
    }

    function testPlacingAndAdjustingFloorBid() public {
        //Offer punk 1 for 100 ether;
        _CryptoPunksMarket.offerPunkForSale(1, 95 ether);

        //Place floor bid for 90 ether;
        uint256 _bidId = _CryptoPunksBidsV1.placeBid{value: 90.01 ether}(90 ether, 0.01 ether, address(0x0), _emptyPunkArray);

        (uint96 _bidWeiBefore, uint96 _settlementWeiBefore,,) = _CryptoPunksBidsV1.globalBids(_bidId);
        assertEq(_bidWeiBefore, 90 ether);
        assertEq(_settlementWeiBefore, 0.01 ether);

        //Increase by 5
        _CryptoPunksBidsV1.adjustBidPrice{value: 5 ether}(_bidId, 5 ether, true);

        //Increase by 0.02 settlement
        _CryptoPunksBidsV1.adjustBidSettlementPrice{value: 0.02 ether}(_bidId, 0.02 ether, true);

        (uint96 _bidWeiAfter, uint96 _settlementWeiAfter,,) = _CryptoPunksBidsV1.globalBids(_bidId);
        assertEq(_bidWeiAfter, 95 ether);
        assertEq(_settlementWeiAfter, 0.03 ether);

        //Anyone can call this function.
        _CryptoPunksBidsV1.acceptBid(_bidId, 1);
    }
}
