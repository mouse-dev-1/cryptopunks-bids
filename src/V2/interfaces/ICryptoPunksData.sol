//SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

interface ICryptoPunksData {
    function punkAttributes(uint16 index) external view returns(string memory);
    function addPunks(uint8 index, bytes memory _punks) external;
}
