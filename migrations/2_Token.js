const Token = artifacts.require("Token");
const CustomLibrary = artifacts.require("customLib");

module.exports = function(deployer, accounts) {
    CustomLibrary.address = "0xc0b843678E1E73c090De725Ee1Af6a9F728E2C47"
    deployer.link(CustomLibrary, Token);
    deployer.deploy(Token, { value: "100" })
};