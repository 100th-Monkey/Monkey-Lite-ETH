pragma solidity ^0.5.6;

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

    Round public round;
    Cycle public cycle;
    uint256 public roundsCount;

    Round[] public unfinished;
    uint256 public finishedCount;

    event AdminFeePayed(address wallet, uint256 amount);
    event RoundFinished(address round);
    event CycleFinished(address cycle);

    constructor() public {
        round = new Round();
        cycle = new Cycle();
    }

    function() external payable {
        finishAndBuy(0, new uint[](0));
    }

    function finishAndBuy(uint startIndex, uint[] memory begins) public payable {
        finish(startIndex, begins);

        uint256 tokenAmount = msg.value.div(TOKEN_PRICE);
        _buy(msg.sender, msg.value, tokenAmount);

        uint256 remainder = msg.value.sub(tokenAmount.mul(TOKEN_PRICE));
        msg.sender.transfer(remainder);
    }

    function finish(uint startIndex, uint[] memory begins) public {
        uint i = 0;
        while (finishedCount < unfinished.length) {
            Round r = unfinished[finishedCount];
            if (r.revealBlockNumber() >= block.number) {
                break;
            }

            uint256 blockHash = uint256(blockhash(r.revealBlockNumber()));
            if (blockHash == 0) {
                r.finish();
                break;
            }

            uint256 offset = blockHash % r.totalBalance();
            (bool res,) = address(r).call(abi.encodeWithSelector(r.award.selector, offset, begins[finishedCount - startIndex]));
            if (!res) {
                break;
            }

            emit RoundFinished(address(r));
            finishedCount += 1;
            i++;
        }
    }

    function _buy(address payable user, uint256 value, uint256 amount) internal {
        require(amount > 0);
        
        round.add.value(value.mul(ROUND_PERCENT).div(100))(user, amount);
        cycle.add.value(value.mul(CYCLE_PERCENT).div(100))(user, amount);
        address(uint160(owner())).send(value.mul(ADMIN_PERCENT).div(100));

        if (round.totalBalance() >= TOKENS_PER_ROUND) {
            emit RoundFinished(address(round));
            round.finish();
            unfinished.push(round);
            round = new Round();
            roundsCount += 1;
        }

        if (roundsCount % ROUNDS_PER_CYCLE == 0) {
            emit CycleFinished(address(cycle));
            cycle.finish();
            unfinished.push(cycle);
            cycle = new Cycle();
        }
    }
}
