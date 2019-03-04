pragma solidity ^0.5.0;


contract Random {
    struct RandomValue {
        uint8 nextBitIndex;
        uint120 lastBlockNumber;
        uint128 value;
    }

    function inProgress(RandomValue storage self) internal view returns(bool) {
        return self.nextBitIndex < 120;
    }

    function produceNextBit(RandomValue storage self) internal returns(bool ready) {
        require(self.lastBlockNumber != block.number);
        uint256 randomBit = latestAvailableBlockHashLeastBit();
        self.nextBitIndex += 1;
        self.lastBlockNumber = uint120(block.number);
        self.value += uint120(randomBit << self.nextBitIndex);
        return self.nextBitIndex == 120;
    }

    function latestAvailableBlockHashLeastBit() private view returns(uint256) {
        return uint256(blockhash(block.number - 1)) % 2;
    }
}
