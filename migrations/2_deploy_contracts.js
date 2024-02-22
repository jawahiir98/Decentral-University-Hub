const Tokens = artifacts.require('Tokens');
const Payments = artifacts.require('Payments');

module.exports = async function(deployer, accounts){
    await deployer.deploy(Tokens) 
    const tokens = await Tokens.deployed()
    await deployer.deploy(Payments, tokens.address) 
    //const payments = await Payments.deployed()
};