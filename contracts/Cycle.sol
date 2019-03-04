pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "./Round.sol";


contract Cycle is Round, ERC20 {
    string constant public name = "Monkey.game Banana Token";
    string constant public symbol = "BT";
    uint8 constant public decimals = 18;

    function add(address payable user, uint256 amount) public payable {
        super.add(user, amount);
        _mint(user, amount);
    }

    function transfer(address /*to*/, uint256 /*value*/) public returns (bool) {
        revert();
    }

    function approve(address /*spender*/, uint256 /*value*/) public returns (bool) {
        revert();
    }

    function transferFrom(address /*from*/, address /*to*/, uint256 /*value*/) public returns (bool) {
        revert();
    }
}
