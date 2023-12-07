// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

    struct Offer {
        bool isForSale;
        uint punkIndex;
        address seller;
        uint minValue;          // in ether
        address onlySellTo;     // specify to sell only to a specific person
    }

interface ICryptoPunksMarket {
    //0x088f11f3
    function punksOfferedForSale(uint)
        external
        view
        returns (Offer memory);

    function punkIndexToAddress(uint256 _punkIndex)
        external
        view
        returns (address);

    function buyPunk(uint256 _punkIndex) external payable;

    function transferPunk(address to, uint256 punkIndex) external;

    function allInitialOwnersAssigned() external;

    function offerPunkForSale(uint, uint) external;

    function getPunk(uint) external;
}
