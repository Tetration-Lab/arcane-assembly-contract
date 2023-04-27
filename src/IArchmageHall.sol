// SPDX-License-Identifier: MIT
// author: yoyoismee.eth (https://twitter.com/0xyoyoismee)

pragma solidity ^0.8.17;

interface IArchmageHall {
    // check if a minion belong to an archmage.
    function haveMaster(address _minion) external view returns (bool);

    // check if an address is an archmage.
    function isArchmage(address _archmage) external view returns (bool);

    // get master of a minion.
    function getMaster(address _minion) external view returns (address);
}
