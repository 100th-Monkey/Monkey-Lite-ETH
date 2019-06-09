pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "./HodlPot.sol";
import "./Round.sol";
import "./Cycle.sol";


contract Monkey {
    using SafeMath for uint;

    uint256 constant public TOKEN_PRICE = 0.02 ether;
    uint256 constant public TOKENS_PER_ROUND = 2000;
    uint256 constant public ROUNDS_PER_CYCLE = 100;

    uint256 constant public ADMIN_PERCENT = 1;
    uint256 constant public ROUND_PERCENT = 30;
    uint256 constant public MINI_ROUND_PERCENT = 9;
    uint256 constant public CYCLE_PERCENT = 30;
    uint256 constant public HODLPOT_PERCENT = 30;

    address public admin;
    Round public round;
    Round public miniRound;
    Cycle public cycle;
    HodlPot public hodlPot;
    uint256 public roundsCount;

    Round[] public unfinished;
    uint256 public finishedCount;

    event AdminFeePayed(address wallet, uint256 amount);
    event RoundFinished(address round);
    event CycleFinished(address cycle);
    event FeePaid(uint256 amount);

    constructor() public {
        admin = msg.sender;
        round = new Round();
        miniRound = new Round();
        cycle = new Cycle();
        hodlPot = new HodlPot();
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

            bytes32 randomBytes = keccak256(abi.encodePacked(blockHash, finishedCount));
            uint256 offset = uint256(randomBytes) % r.totalBalance();
            bool res = address(r).call(abi.encodeWithSelector(r.award.selector, offset, begins[finishedCount - startIndex]));
            if (!res) {
                break;
            }

            emit RoundFinished(address(r));
            finishedCount += 1;
            i++;
        }
    }

    function _buy(address user, uint256 value, uint256 amount) internal {
        require(amount > 0);

        round.add.value(value.mul(ROUND_PERCENT).div(100))(user, amount);
        miniRound.add.value(value.mul(MINI_ROUND_PERCENT).div(100))(user, amount);
        cycle.add.value(value.mul(CYCLE_PERCENT).div(100))(user, amount);
        hodlPot.put.value(value.mul(HODLPOT_PERCENT).div(100))(user);
        if (admin.send(value.mul(ADMIN_PERCENT).div(100))) {
            emit FeePaid(value.mul(ADMIN_PERCENT).div(100));
        }

        if (round.totalBalance() >= TOKENS_PER_ROUND) {
            emit RoundFinished(address(round));
            round.finish();
            miniRound.finish();
            unfinished.push(round);
            unfinished.push(miniRound);
            round = new Round();
            miniRound = new Round();
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
