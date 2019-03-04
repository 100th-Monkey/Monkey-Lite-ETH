pragma solidity ^0.5.0;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract Round is Ownable {
    using SafeMath for uint;

    struct Range {
        uint256 end;
        address payable user;
    }

    mapping(uint256 => Range) public ranges;
    mapping(address => uint256) public balances;
    uint256 public totalBalance;
    
    event RangeAdded(uint256 begin, uint256 length, address indexed user);

    function add(address payable user, uint256 amount) public payable onlyOwner {
        uint256 begin = totalBalance;
        totalBalance = totalBalance.add(amount);
        balances[user] = balances[user].add(amount);
        ranges[begin] = Range({
            end: totalBalance,
            user: user
        });
        emit RangeAdded(begin, totalBalance, user);
    }

    function award(uint256 offset, uint256 begin) public onlyOwner {
        require(begin <= offset && offset < ranges[begin].end);
        selfdestruct(ranges[begin].user);
    }
}
