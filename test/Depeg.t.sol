// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {LRTCONFIG} from "./interfaces/LRTCONFIG.sol";

contract DepegTest is Test {

    LRTCONFIG _lrtConfig = LRTCONFIG(0x349A73444b1a310BAe67ef67973022020d70020d);
    address STETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address ETHX = 0xA35b1B31Ce002FBF2058D22F30f95D405200A15b;
    address SFRXETH = 0xac3E018457B222d93114458476f3E3416Abbe38F;

    function test_feeds() public {
        uint256 stETH_price = _lrtConfig.getAssetPrice(STETH);
        uint256 ETHx_price = _lrtConfig.getAssetPrice(ETHX);
        uint256 sfrxETH_price = _lrtConfig.getAssetPrice(SFRXETH);
        console2.log("stETH:",stETH_price);
        console2.log("ETHx:",ETHx_price);
        console2.log("sfrxETH:",sfrxETH_price);
    }

}