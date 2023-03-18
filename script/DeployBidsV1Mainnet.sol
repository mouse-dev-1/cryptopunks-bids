// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/V1/CryptoPunksBidsV1.sol";

contract DeployBidsV1Mainnet is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new CryptoPunksBidsV1(0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB);

        vm.stopBroadcast();
    }
}