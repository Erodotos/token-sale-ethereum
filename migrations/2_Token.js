const Token = artifacts.require("Token");

module.exports = function(deployer, accounts) {
    deployer.deploy(Token, { value: "1000000000000000000" })
};