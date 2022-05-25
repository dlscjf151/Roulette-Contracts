const Roulette = artifacts.require('Roulette');
const VRFv2Consumer = artifacts.require('VRFv2Consumer');
const chai = require('chai');
const {expectRevert, expectEvent} = require('@openzeppelin/test-helpers')
const {expect} = require("chai");


contract("Roulette", async accounts => {
    let events;
    let blockNumber;
    let requestId;

    it("should revert transaction", async () => {
        let roulette = await Roulette.deployed();
        await expectRevert.unspecified(roulette.bet(0, {from: accounts[0]}));
        await expectRevert.unspecified(roulette.bet(100, {from: accounts[0]}));
    })

    it("bet", async () => {
        let roulette = await Roulette.deployed();
        let {tx, receipt} = await roulette.bet(1, {from: accounts[0], value: web3.utils.toWei('0.0001', 'ether')});
        blockNumber = receipt.blockNumber;
        // console.log(receipt)
        await expectEvent.inTransaction(tx, roulette, 'Bet');
        let log = receipt.logs[0]
        // console.log(log.args)
        requestId = '0x' + log.args.requestId.toString(16);
        console.log(requestId)
    })

    it("reveal", async () => {
        let roulette = await Roulette.deployed();

        for (let i = 0; i < 20; i++) {
            events = await web3.eth.getPastLogs({
                fromBlock: blockNumber,
                toBlock: "latest",
                topics: [
                    "0x7dffc5ae5ee4e2e4df1651cf6ad329a73cebdb728f37ea0187b9b17e036756e4",
                    requestId
                ]
            })
            if (events.length > 0) {
                break;
            }
            await sleep(5000);
        }

        let _VRFv2Consumer = await VRFv2Consumer.deployed()
        let random = await _VRFv2Consumer.getRandom.call(requestId)
        console.log(random, random % 2);

        let {tx, receipt} = await roulette.reveal({from: accounts[0]});
        console.log(receipt)
        let logs = receipt.logs
        expect(events.length).to.equal(1);
        console.log(logs)
    })
})

async function sleep(ms) {
    return new Promise(r => setTimeout(r, ms))
}