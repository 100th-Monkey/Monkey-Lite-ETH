const Monkey = artifacts.require('Monkey');

contract('Monkey', function ([_, addr1]) {
    describe('Monkey', async function () {
        it('should be ok', async function () {
            this.token = await Monkey.new();
        });
    });
});
