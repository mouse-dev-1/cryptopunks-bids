// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/CryptoPunksBidsV1.sol";

contract DeployBidsV1Testnet is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        new CryptoPunksBidsV1(0xdCb2C6c26fb811b1e29De3AbeC6cd7765926a541);

        vm.stopBroadcast();
    }
}