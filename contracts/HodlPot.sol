pragma solidity ^0.4.25;

import "openzeppelin-solidity/contracts/math/SafeMath.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";


contract HodlPot is Ownable {
    using SafeMath for uint256;

    uint256 constant public percentsRemaining = 50;
    mapping(address => uint256) public shares;
    uint256 public totalShares;
    bool public finished;

    function put(address user) public payable onlyOwner {
        uint256 amount = msg.value;
        if (totalShares > 0) {
            amount = msg.value.mul(totalShares).div(address(this).balance.sub(msg.value));
        }
        shares[user] = shares[user].add(amount);
        totalShares = totalShares.add(amount);
    }

    function get(address user) public onlyOwner {
        require(finished);

        uint256 amount = balanceOf(user);
        totalShares = totalShares.sub(shares[user]);
        shares[user] = 0;
        user.transfer(amount);
        if (totalShares == 0) {
            selfdestruct(user);
        }
    }

    function finish() public onlyOwner {
        finished = true;
    }

    function balanceOf(address _account) public view returns(uint256) {
        if (totalShares == 0) {
            return 0;
        }
        return address(this).balance.mul(shares[_account]).mul(percentsRemaining).div(totalShares).div(100);
    }
}
