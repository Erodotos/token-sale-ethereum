const Token = artifacts.require("Token");

const chai = require("./chaisetup.js");
const BN = web3.utils.BN;
const expect = chai.expect;

// require("dotenv").config({ path: '../.env' });

contract("Token Test", async (accounts) => {


    beforeEach(async () => {
        this.Token = await Token.new({ value: "1000000000000000000" });
    });

    it("Deployer account should be the owner", async () => {
        let instance = this.Token;
        let owner = await instance.owner();
        return expect(owner).equal(accounts[0]);
    });

    it("Owner should provide liquidity of 1 ETH", async () => {
        let instance = this.Token;
        let owner = await instance.owner();
        let liquidity = await instance.liquidityProviders(owner);
        return expect(liquidity).to.be.a.bignumber.equal(new BN(1000000000000000000n));
    });

    it("Can provide liquidity", async () => {
        const liquidity = 100;
        const liquidityProvider = accounts[1];
        let instance = this.Token;
        let initialLiquidity = await instance.totalLiquidity();
        await instance.sendTransaction({ from: liquidityProvider, value: liquidity });
        let newLiquidity = await instance.totalLiquidity();
        return expect(newLiquidity).to.be.a.bignumber.greaterThan(initialLiquidity);
    });

    it("Liquidity provider can receive rewards", async () => {
        let instance = this.Token;
        let balanceOfAccount = await instance.balances(accounts[0]);
        await expect(balanceOfAccount).to.be.a.bignumber.equal(new BN(0));

        let poolFunds = await instance.rewardsPool();
        console.log(BigInt(poolFunds))
        await instance.buyToken(10, { from: accounts[1], value: 100 })
        poolFunds = await instance.rewardsPool();
        console.log(BigInt(poolFunds))

        await instance.sendTransaction({ from: accounts[0], value: 0 })

        poolFunds = await instance.rewardsPool();
        console.log(BigInt(poolFunds))

        balanceOfAccount = await instance.balances(accounts[0]);
        console.log(BigInt(balanceOfAccount))
        return expect(balanceOfAccount).to.be.a.bignumber.equal(new BN(1));
    });

    // it("It's not possible to send more tokens than account 1 has", async() => {
    //     let instance = this.helloToken;
    //     let balanceOfAccount = await instance.balanceOf(initialHolder);
    //     await expect(instance.transfer(recipient, new BN(balanceOfAccount + 1))).to.eventually.be.rejected;
    //     return expect(instance.balanceOf(initialHolder)).to.eventually.be.a.bignumber.equal(balanceOfAccount);
    // });

});