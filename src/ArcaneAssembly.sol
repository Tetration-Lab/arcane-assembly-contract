// SPDX-License-Identifier: MIT
// author: yoyoismee.eth (https://twitter.com/0xyoyoismee)

pragma solidity ^0.8.17;
import "./IArchmageHall.sol";

contract ArcaneAssembly {
    event Invoked(
        string indexed ritualName,
        address indexed invoker,
        uint256 indexed ritualID,
        string tauIPFS, // power of tau file
        string runeIPFS, // circuit file (optional)
        string arcaneIPFS, // current state
        string ritualType
    );
    event Channeled(
        string indexed ritualName,
        bytes32 indexed parentID,
        bytes32 indexed contribID,
        address contributor,
        string arcaneIPFS
    );
    event Attested(
        string indexed ritualName,
        bytes32 indexed contribID,
        address indexed attester
    );
    event Flag(
        string indexed ritualName,
        bytes32 indexed contribID,
        address indexed flagger
    );

    event Summoned(string indexed ritualName, uint256 indexed ritualID);
    struct ArcaneState {
        uint256 ritualID;
        string arcaneIPFS;
        bytes32 parentID;
        uint32 nContrib;
        uint32 nArchmage;
        uint32 nAttest;
        uint32 nFlag;
    }
    struct Ritual {
        string ritualName;
        string tauIPFS;
        string runeIPFS;
        string rootArcaneIPFS;
        string ritualType;
        address invoker;
        bool isActive;
    }
    uint256 idx = 420; // magic start at 420
    mapping(bytes32 => ArcaneState) public arcaneStates;
    mapping(uint256 => Ritual) public rituals;
    IArchmageHall public archmageHall;

    constructor(address _archmageHall) {
        archmageHall = IArchmageHall(_archmageHall);
    }

    // start a ritual. wait for people from all over the world to contribute.
    function invoke(
        string calldata _ritualName,
        string calldata _tauIPFS,
        string calldata _runeIPFS,
        string calldata _arcaneIPFS,
        string calldata _ritualType
    ) public {
        rituals[idx] = Ritual({
            ritualName: _ritualName,
            tauIPFS: _tauIPFS,
            runeIPFS: _runeIPFS,
            rootArcaneIPFS: _arcaneIPFS,
            ritualType: _ritualType,
            invoker: msg.sender,
            isActive: true
        });
        bytes32 arcaneID = keccak256(abi.encodePacked(idx, msg.sender));
        arcaneStates[arcaneID] = ArcaneState({
            ritualID: idx,
            arcaneIPFS: _arcaneIPFS,
            parentID: bytes32(idx),
            nContrib: 0,
            nArchmage: 0,
            nAttest: 0,
            nFlag: 0
        });
        emit Invoked(
            _ritualName,
            msg.sender,
            idx,
            _tauIPFS,
            _runeIPFS,
            _arcaneIPFS,
            _ritualType
        );
        emit Channeled(
            _ritualName,
            bytes32(idx),
            arcaneID,
            msg.sender,
            _arcaneIPFS
        );
    }

    // signal that the ritual is finished.
    function finish(uint256 _ritualID) public {
        require(rituals[_ritualID].invoker == msg.sender, "Not the invoker");
        rituals[_ritualID].isActive = false;
        emit Summoned(rituals[_ritualID].ritualName, _ritualID);
    }

    // channel your power into the ritual. the more people contribute, the more powerful the ritual.
    // archmage contribute more power.
    function channel(bytes32 _parentID, string calldata _arcaneIPFS) public {
        bytes32 arcaneID = keccak256(abi.encodePacked(_parentID, msg.sender));
        require(arcaneStates[arcaneID].ritualID == 0, "already exist");
        ArcaneState memory parent = arcaneStates[_parentID];

        arcaneStates[arcaneID] = ArcaneState({
            ritualID: parent.ritualID,
            arcaneIPFS: _arcaneIPFS,
            parentID: _parentID,
            nContrib: parent.nContrib + 1,
            nArchmage: parent.nArchmage +
                (archmageHall.haveMaster(msg.sender) ? 1 : 0),
            nAttest: 0,
            nFlag: parent.nFlag
        });

        emit Channeled(
            rituals[arcaneStates[_parentID].ritualID].ritualName,
            _parentID,
            arcaneID,
            msg.sender,
            _arcaneIPFS
        );
    }

    // archmage can attest arcanes.
    // we trust archmage expertise in examining arcane's correctness.
    function attest(bytes32 _contribID) public {
        require(arcaneStates[_contribID].ritualID != 0, "not exist");
        require(archmageHall.haveMaster(msg.sender), "not minion");

        arcaneStates[_contribID].nAttest++;
        emit Attested(
            rituals[arcaneStates[_contribID].ritualID].ritualName,
            _contribID,
            archmageHall.getMaster(msg.sender)
        );
    }

    function flag(bytes32 _contribID) public {
        require(arcaneStates[_contribID].ritualID != 0, "not exist");
        require(archmageHall.haveMaster(msg.sender), "not minion");
        arcaneStates[_contribID].nFlag++;
        emit Flag(
            rituals[arcaneStates[_contribID].ritualID].ritualName,
            _contribID,
            msg.sender
        );
    }
}
