pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract Round is Ownable {
    using SafeMath for uint;

    struct Range {
        uint256 end;
        address user;
    }

    mapping(uint256 => Range) public ranges;
    mapping(address => uint256) public balances;
    uint256 public totalBalance;
    uint256 public revealBlockNumber;
    
    event RangeAdded(address indexed user, uint256 begin, uint256 length);
    event RoundFinished();
    event RoundAwarded(address indexed user);

    function add(address user, uint256 amount) public payable onlyOwner {
        uint256 begin = totalBalance;
        totalBalance = totalBalance.add(amount);
        balances[user] = balances[user].add(amount);
        ranges[begin] = Range({
            end: totalBalance,
            user: user
        });
        emit RangeAdded(user, begin, totalBalance);
    }

    function finish() public onlyOwner {
        revealBlockNumber = block.number + 1;
        emit RoundFinished();
    }

    function award(uint256 offset, uint256 begin) public onlyOwner {
        require(block.number > revealBlockNumber);
        require(begin <= offset && offset < ranges[begin].end);
        emit RoundAwarded(ranges[begin].user);
        selfdestruct(ranges[begin].user);
    }
}
