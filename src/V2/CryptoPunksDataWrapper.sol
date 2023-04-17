// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/*

CryptoPunksDataWrapper.sol

Written by: mousedev.eth

Concept by: mousedev.eth & kilo

*/

import "./strings.sol";
import "./interfaces/ICryptoPunksData.sol";
import "forge-std/console.sol";

struct TraitFilter {
    //true - inclusive
    //false - exclusive
    bool direction;

    //What id from 0-97 you want to target.
    uint8 traitId;
}

abstract contract CryptoPunksDataWrapper {
    using Strings for string;

    address public cryptoPunksDataAddress;

    mapping(uint8 => bytes32) public traitIdToHash;

    function setAllTraits() internal {
        traitIdToHash[0] = keccak256("Female 2");
        traitIdToHash[1] = keccak256("Earring");
        traitIdToHash[2] = keccak256("Blonde Bob");
        traitIdToHash[3] = keccak256("Green Eye Shadow");
        traitIdToHash[4] = keccak256("Male 1");
        traitIdToHash[5] = keccak256("Smile");
        traitIdToHash[6] = keccak256("Mohawk");
        traitIdToHash[7] = keccak256("Female 3");
        traitIdToHash[8] = keccak256("Wild Hair");
        traitIdToHash[9] = keccak256("Pipe");
        traitIdToHash[10] = keccak256("Nerd Glasses");
        traitIdToHash[11] = keccak256("Male 2");
        traitIdToHash[12] = keccak256("Goat");
        traitIdToHash[13] = keccak256("Big Shades");
        traitIdToHash[14] = keccak256("Half Shaved");
        traitIdToHash[15] = keccak256("Purple Eye Shadow");
        traitIdToHash[16] = keccak256("Do-rag");
        traitIdToHash[17] = keccak256("Spots");
        traitIdToHash[18] = keccak256("Wild White Hair");
        traitIdToHash[19] = keccak256("Clown Eyes Blue");
        traitIdToHash[20] = keccak256("Luxurious Beard");
        traitIdToHash[21] = keccak256("Messy Hair");
        traitIdToHash[22] = keccak256("Big Beard");
        traitIdToHash[23] = keccak256("Police Cap");
        traitIdToHash[24] = keccak256("Clown Nose");
        traitIdToHash[25] = keccak256("Female 1");
        traitIdToHash[26] = keccak256("Blue Eye Shadow");
        traitIdToHash[27] = keccak256("Black Lipstick");
        traitIdToHash[28] = keccak256("Straight Hair Dark");
        traitIdToHash[29] = keccak256("Clown Eyes Green");
        traitIdToHash[30] = keccak256("Purple Lipstick");
        traitIdToHash[31] = keccak256("Blonde Short");
        traitIdToHash[32] = keccak256("Straight Hair Blonde");
        traitIdToHash[33] = keccak256("Hot Lipstick");
        traitIdToHash[34] = keccak256("Pilot Helmet");
        traitIdToHash[35] = keccak256("Male 4");
        traitIdToHash[36] = keccak256("Regular Shades");
        traitIdToHash[37] = keccak256("Stringy Hair");
        traitIdToHash[38] = keccak256("Small Shades");
        traitIdToHash[39] = keccak256("Male 3");
        traitIdToHash[40] = keccak256("Frown");
        traitIdToHash[41] = keccak256("Muttonchops");
        traitIdToHash[42] = keccak256("Eye Mask");
        traitIdToHash[43] = keccak256("Bandana");
        traitIdToHash[44] = keccak256("Horned Rim Glasses");
        traitIdToHash[45] = keccak256("Crazy Hair");
        traitIdToHash[46] = keccak256("Classic Shades");
        traitIdToHash[47] = keccak256("Handlebars");
        traitIdToHash[48] = keccak256("Mohawk Dark");
        traitIdToHash[49] = keccak256("Dark Hair");
        traitIdToHash[50] = keccak256("Peak Spike");
        traitIdToHash[51] = keccak256("Normal Beard Black");
        traitIdToHash[52] = keccak256("Cap");
        traitIdToHash[53] = keccak256("VR");
        traitIdToHash[54] = keccak256("Frumpy Hair");
        traitIdToHash[55] = keccak256("Normal Beard");
        traitIdToHash[56] = keccak256("Cigarette");
        traitIdToHash[57] = keccak256("Red Mohawk");
        traitIdToHash[58] = keccak256("Shaved Head");
        traitIdToHash[59] = keccak256("Chinstrap");
        traitIdToHash[60] = keccak256("Mole");
        traitIdToHash[61] = keccak256("Knitted Cap");
        traitIdToHash[62] = keccak256("Fedora");
        traitIdToHash[63] = keccak256("Shadow Beard");
        traitIdToHash[64] = keccak256("Straight Hair");
        traitIdToHash[65] = keccak256("Hoodie");
        traitIdToHash[66] = keccak256("Eye Patch");
        traitIdToHash[67] = keccak256("Headband");
        traitIdToHash[68] = keccak256("Cowboy Hat");
        traitIdToHash[69] = keccak256("Tassle Hat");
        traitIdToHash[70] = keccak256("3D Glasses");
        traitIdToHash[71] = keccak256("Mustache");
        traitIdToHash[72] = keccak256("Vape");
        traitIdToHash[73] = keccak256("Choker");
        traitIdToHash[74] = keccak256("Pink With Hat");
        traitIdToHash[75] = keccak256("Welding Goggles");
        traitIdToHash[76] = keccak256("Vampire Hair");
        traitIdToHash[77] = keccak256("Mohawk Thin");
        traitIdToHash[78] = keccak256("Tiara");
        traitIdToHash[79] = keccak256("Zombie");
        traitIdToHash[80] = keccak256("Front Beard Dark");
        traitIdToHash[81] = keccak256("Gold Chain");
        traitIdToHash[82] = keccak256("Cap Forward");
        traitIdToHash[83] = keccak256("Purple Hair");
        traitIdToHash[84] = keccak256("Beanie");
        traitIdToHash[85] = keccak256("Clown Hair Green");
        traitIdToHash[86] = keccak256("Pigtails");
        traitIdToHash[87] = keccak256("Silver Chain");
        traitIdToHash[88] = keccak256("Front Beard");
        traitIdToHash[89] = keccak256("Rosy Cheeks");
        traitIdToHash[90] = keccak256("Orange Side");
        traitIdToHash[91] = keccak256("Female 4");
        traitIdToHash[92] = keccak256("Wild Blonde");
        traitIdToHash[93] = keccak256("Buck Teeth");
        traitIdToHash[94] = keccak256("Top Hat");
        traitIdToHash[95] = keccak256("Medical Mask");
        traitIdToHash[96] = keccak256("Ape");
        traitIdToHash[97] = keccak256("Alien");
    }

    function isPunkCompatible(
        bytes memory _traitFilters,
        uint16 _punkId
    ) public view returns (bool) {
        string memory traitsString = ICryptoPunksData(cryptoPunksDataAddress)
            .punkAttributes(_punkId);

        TraitFilter[] memory _traitFiltersDecoded = new TraitFilter[](
            _traitFilters.length / 2
        );

        for (uint i = 0; i < _traitFilters.length / 2; i++) {
            //Pull direction from bytes
            _traitFiltersDecoded[i].direction = _traitFilters[i * 2] == hex"00"
                ? false
                : true;
            //Pull traitId from bytes
            _traitFiltersDecoded[i].traitId = uint8(_traitFilters[i * 2 + 1]);
        }

        //Assembles an array of a hash of every trait
        bytes32[] memory _traitsSplit = traitsString.split(",");

        for (uint i = 0; i < _traitFiltersDecoded.length; i++) {
            if (_traitFiltersDecoded[i].direction) {
                for (uint256 j = 0; j < _traitsSplit.length; j++) {
                    console.logBytes32(_traitsSplit[j]);
                    console.logBytes32(
                        traitIdToHash[_traitFiltersDecoded[i].traitId]
                    );
                    console.log(
                        _traitsSplit[j] ==
                            traitIdToHash[_traitFiltersDecoded[i].traitId]
                    );

                    //If the trait is found on the punk, break out of this loop
                    if (
                        _traitsSplit[j] ==
                        traitIdToHash[_traitFiltersDecoded[i].traitId]
                    ) break;
                    //If we haven't broken out yet, return false.
                    if (j == _traitsSplit.length - 1) {
                        console.log("Included trait not found on punk!");
                        return false;
                    }
                }
            } else {
                for (uint256 j = 0; j < _traitsSplit.length; j++) {
                    //If the trait is found on the punk, return false
                    if (
                        _traitsSplit[j] ==
                        traitIdToHash[_traitFiltersDecoded[i].traitId]
                    ) {
                        console.log("Excluded trait found on punk!");
                        return false;
                    }
                }
            }
        }

        return true;
    }
}
