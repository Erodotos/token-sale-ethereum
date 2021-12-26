const Web3 = require('web3');

var web3 = new Web3(new Web3.providers.HttpProvider('https://ropsten.infura.io/v3/0ab1814012ad4231965d67bf98a40b1a'));

var contract_address = '0xde3a17573B0128da962698917B17079f2aAbebea';

web3.eth.getStorageAt(contract_address, 1).then(result => {
    console.log(web3.utils.hexToString(result));
});