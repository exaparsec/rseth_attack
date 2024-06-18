// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test, console2} from "forge-std/Test.sol";
import {ILRTCONFIG} from "./interfaces/ILRTCONFIG.sol";
import {ILRTDepositPool} from "./interfaces/ILRTDepositPool.sol";
import {IERC20} from "./interfaces/IERC20.sol";

contract DepegTest is Test {

    address RSETH = 0xA1290d69c65A6Fe4DF752f95823fae25cB99e5A7;

    address STETH_PROXY = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84; // fail to write value
    address STETH = 0x17144556fd3424EDC8Fc8A4C940B2D04936d17eb; // slot not found

    address ETHX = 0xA35b1B31Ce002FBF2058D22F30f95D405200A15b;
    address SFRXETH = 0xac3E018457B222d93114458476f3E3416Abbe38F;

    ILRTCONFIG _lrtConfig = ILRTCONFIG(0x349A73444b1a310BAe67ef67973022020d70020d);
    ILRTDepositPool _lrtDepositPool = ILRTDepositPool(0x036676389e48133B63a802f8635AD39E752D375D);
    IERC20 _ethx = IERC20(ETHX);
    IERC20 _rseth = IERC20(RSETH);

    function test_feeds() public {
        uint256 stETH_price = _lrtConfig.getAssetPrice(STETH_PROXY);
        uint256 ETHx_price = _lrtConfig.getAssetPrice(ETHX);
        uint256 sfrxETH_price = _lrtConfig.getAssetPrice(SFRXETH);
        console2.log("stETH:",stETH_price);
        console2.log("ETHx:",ETHx_price);
        console2.log("sfrxETH:",sfrxETH_price);
    }

    function test_withdraw_another_lsd() public {
        address alice = makeAddr("alice");
        emit log_address(alice);
        vm.startPrank(alice);

        // acquire 100 ETHx for 1 ETH on secondary market
        deal(address(ETHX), alice, 100 ether);

        // check how many rsETH we can get for 100 ETHx
        uint256 rsETH_amount_to_receive = _lrtDepositPool.getRsETHAmountToMint(address(ETHX), 100 ether);
        console2.log("rsETH to get for 100 ETHx = ", rsETH_amount_to_receive / 1e18);

        // deposit 100 ETHx for 100 rsETH in KelpDAO
        _ethx.approve(address(_lrtDepositPool), 100 ether);
        console2.log("ETHx balance before transfer = ", _ethx.balanceOf(address(alice)) / 1e18);
        console2.log("rsETH balance before transfer = ", _rseth.balanceOf(address(alice)) / 1e18);
        _lrtDepositPool.depositAsset(address(ETHX), 100 ether, rsETH_amount_to_receive, "42");
        console2.log("ETHx balance after transfer = ", _ethx.balanceOf(address(alice)) / 1e18);
        console2.log("rsETH balance after transfer = ", _rseth.balanceOf(address(alice)) / 1e18);

        // withdraw stETH by burning
        //_rseth.approve(address(_), 100 ether);
    }
}