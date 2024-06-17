// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

interface LRTCONFIG {
    function getAssetPrice(address) external view returns (uint256);
}