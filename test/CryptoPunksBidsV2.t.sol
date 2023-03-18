// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {ICryptoPunksMarket} from "../src/V2/interfaces/ICryptoPunksMarket.sol";
import {ICryptoPunksData} from "../src/V2/interfaces/ICryptoPunksData.sol";
import {TraitFilter} from "../src/V2/CryptoPunksDataWrapper.sol";
import {CryptoPunksBidsV2} from "../src/V2/CryptoPunksBidsV2.sol";

contract TestCryptoPunksBidsV2 is Test {
    address _cryptoPunksMarketDeployment = deployCode("CryptoPunksMarket.sol");

    ICryptoPunksMarket internal _CryptoPunksMarket;
    ICryptoPunksData internal _CryptoPunksData;
    CryptoPunksBidsV2 internal _CryptoPunksBidsV2;

    //For receiving ether.
    fallback() external payable {}

    function setUp() public {
        _CryptoPunksMarket = ICryptoPunksMarket(_cryptoPunksMarketDeployment);

        _CryptoPunksMarket.allInitialOwnersAssigned();

        //Get sum punks.
        _CryptoPunksMarket.getPunk(3328);
        _CryptoPunksMarket.getPunk(4874);

        
        _CryptoPunksMarket.getPunk(117);
        _CryptoPunksMarket.getPunk(5253);
        
        _CryptoPunksData = ICryptoPunksData(0x16F5A35647D6F03D5D3da7b35409D65ba03aF3B2);

        _CryptoPunksBidsV2 = new CryptoPunksBidsV2(address(_CryptoPunksMarket), address(_CryptoPunksData));
    }

    function testPlacingAndAcceptingFloorBid() public {
        //Offer punk 1 for 100 ether;
        _CryptoPunksMarket.offerPunkForSale(3328, 100 ether);
        _CryptoPunksMarket.offerPunkForSale(4874, 100 ether);
        _CryptoPunksMarket.offerPunkForSale(117, 100 ether);
        _CryptoPunksMarket.offerPunkForSale(5253, 100 ether);

        TraitFilter[] memory _traitFilters = new TraitFilter[](4);
        _traitFilters[0] = TraitFilter(true, 79);
        _traitFilters[1] = TraitFilter(true, 21);

        _traitFilters[2] = TraitFilter(false, 60);
        _traitFilters[3] = TraitFilter(false, 80);

        //Place floor bid for 110 ether;
        uint256 _bidId = _CryptoPunksBidsV2.placeBid{value: 110.01 ether}(
            110 ether,
            0.01 ether,
            _traitFilters
        );

        //Anyone can call this function.

        //This should fail
        vm.expectRevert("Supplied punk does not match trait choices!");
        _CryptoPunksBidsV2.acceptBid(_bidId, 117);
        //This should fail
        vm.expectRevert("Supplied punk does not match trait choices!");
        _CryptoPunksBidsV2.acceptBid(_bidId, 5253);
        
        //This should succeed
        _CryptoPunksBidsV2.acceptBid(_bidId, 4874);
    }
}
