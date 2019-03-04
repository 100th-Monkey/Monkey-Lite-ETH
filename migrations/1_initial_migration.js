const Migrations = artifacts.require('./Migrations.sol');
const Monkey = artifacts.require('./Monkey.sol');

module.exports = function (deployer) {
    deployer.deploy(Migrations);
    deployer.deploy(Monkey);
};
