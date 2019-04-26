pragma solidity ^0.4.25;


contract Manyownable {
    mapping(address => bool) private _owners;

    event OwnerAdded(address indexed newOwner);
    event OwnerRemoved(address indexed oldOwner);

    constructor () internal {
        _addOwner(msg.sender);
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function isOwner(address who) public view returns (bool) {
        return _owners[who];
    }

    function renounceOwnership() public onlyOwner {
        delete _owners[msg.sender];
        emit OwnerRemoved(msg.sender);
    }

    function addOwner(address newOwner) public onlyOwner {
        _addOwner(newOwner);
    }

    function _addOwner(address newOwner) internal {
        require(!_owners[newOwner]);
        _owners[newOwner] = true;
        emit OwnerAdded(newOwner);
    }
}
