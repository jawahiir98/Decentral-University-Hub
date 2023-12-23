const Tokens = artifacts.require('Tokens');

module.exports = async function(deployer){
    await deployer.deploy(Tokens)
};
