//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ICryptoPunksData {
    function punkAttributes(uint16 index) external returns(string memory);
}
