// SPDX-License-Identifier: MIT
// author: yoyoismee.eth (https://twitter.com/0xyoyoismee)

pragma solidity ^0.8.17;
import "openzeppelin-contracts/access/Ownable.sol";
import "./IArchmageHall.sol";

// ArchmageHall is where the most powerful wizards live.
contract ArchmageHall is Ownable, IArchmageHall {
    event newArchmage(address indexed archmage, string name, string profile);
    event ArchmageUpdated(
        address indexed archmage,
        string name,
        string profile
    );
    event ArchmageExpelled(address indexed archmage);
    event MinionAdded(address indexed master, address indexed minion);
    event MinionRemoved(address indexed minion);

    struct Archmage {
        string name;
        string profile; // link to profile
        bool isArchmage;
    }

    mapping(address => Archmage) public archmages; // list archmage.
    mapping(address => address) public minionOwner; // minon submit tx on behalf of archmage.
    mapping(address => address) public minion; // minion belong to archmage.

    function _changeMinion(address _master, address _minion) internal {
        emit MinionRemoved(minion[_master]);
        minionOwner[minion[_master]] = address(0);
        minion[_master] = _minion;
        if (_minion != address(0)) {
            minionOwner[_minion] = _master;
            emit MinionAdded(_master, _minion);
        }
    }

    // expel an naughty archmage. only the special comitee can do this.
    function expel(address _ded) public onlyOwner {
        delete archmages[_ded];
        _changeMinion(_ded, address(0));
        emit ArchmageExpelled(_ded);
    }

    // promote a new archmage. only the special comitee can do this.
    function promote(
        address _newArchmage,
        string calldata _name,
        string calldata _profile
    ) public onlyOwner {
        archmages[_newArchmage] = Archmage(_name, _profile, true);
        emit newArchmage(_newArchmage, _name, _profile);
    }

    // update archmage profile. only the special comitee can do this.
    function updateArchmage(
        address _archmage,
        string calldata _newName,
        string calldata _newProfile
    ) public onlyOwner {
        archmages[_archmage] = Archmage(_newName, _newProfile, true);
        emit ArchmageUpdated(_archmage, _newName, _newProfile);
    }

    // minion are servant of archmage. they can submit tx on behave of archmage.
    function addMinion(address _minion) public {
        require(archmages[msg.sender].isArchmage, "Not an archmage");
        require(minionOwner[_minion] == address(0), "Minion already exist");
        _changeMinion(msg.sender, _minion);
    }

    // remove minion
    function removeMinion() public {
        require(archmages[msg.sender].isArchmage, "Not an archmage");
        _changeMinion(msg.sender, address(0));
    }

    // check if a minion belong to an archmage.
    function haveMaster(address _minion) public view returns (bool) {
        return minionOwner[_minion] != address(0);
    }

    // check if an address is an archmage.
    function isArchmage(address _archmage) public view returns (bool) {
        return archmages[_archmage].isArchmage;
    }

    // get master of a minion.
    function getMaster(address _minion) public view returns (address) {
        return minionOwner[_minion];
    }
}
