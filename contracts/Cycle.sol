pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/token/ERC20/MintableToken.sol";
import "./Round.sol";


contract Cycle is Round, MintableToken {
    string constant public name = "Monkey.game Banana Token";
    string constant public symbol = "BT";
    uint8 constant public decimals = 18;

    function add(address user, uint256 amount) public payable {
        super.add(user, amount);
        mint(user, amount);
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
