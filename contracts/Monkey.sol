pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./Round.sol";
import "./Cycle.sol";

contract Monkey is Ownable {
    using SafeMath for uint;

    uint256 constant public TOKEN_PRICE = 0.02 ether;
    uint256 constant public TOKENS_PER_ROUND = 2000;
    uint256 constant public ROUNDS_PER_CYCLE = 100;

    uint256 constant public ADMIN_PERCENT = 1;
    uint256 constant public ROUND_PERCENT = 30;
    uint256 constant public CYCLE_PERCENT = 69;

    Round[] public rounds;
    Cycle[] public cycles;

    event AdminFeePayed(address wallet, uint256 amount);

    constructor() public {
        rounds.push(new Round());
        cycles.push(new Cycle());
    }

    function roundsLength() public view returns(uint256) {
        return rounds.length;
    }

    function cyclesLength() public view returns(uint256) {
        return cycles.length;
    }

    function() external payable {
        uint256 tokenAmount = msg.value.div(TOKEN_PRICE);
        _buy(msg.sender, msg.value, tokenAmount);

        uint256 remainder = msg.value.sub(tokenAmount.mul(TOKEN_PRICE));
        msg.sender.transfer(remainder);
    }

    function award(Round game, uint256 begin) public {
        // uint256 offset = winners[game];
        // game.award(offset, begin);
    }

    function _buy(address payable user, uint256 value, uint256 amount) internal {
        require(amount > 0);
        
        rounds[rounds.length - 1].add.value(value.mul(ROUND_PERCENT).div(100))(user, amount);
        cycles[cycles.length - 1].add.value(value.mul(CYCLE_PERCENT).div(100))(user, amount);
        address(uint160(owner())).send(value.mul(ADMIN_PERCENT).div(100));

        if (rounds[rounds.length - 1].totalBalance() >= TOKENS_PER_ROUND) {
            _finish(rounds[rounds.length - 1]);
            rounds.push(new Round());
        }

        if (rounds.length % ROUNDS_PER_CYCLE == 0) {
            _finish(cycles[cycles.length - 1]);
            cycles.push(new Cycle());
        }
    }

    function _finish(Round game) internal {

    }
}
