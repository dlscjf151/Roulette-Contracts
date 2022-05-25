const {expect} = require('chai')
const VRFv2Consumer = artifacts.require("VRFv2Consumer");

contract("VRFv2Consumer", async accounts => {
    let blockNumber;
    let requestId;
    it("should emit event in requestRandomWords function", async () => {
        let _VRFv2Consumer = await VRFv2Consumer.deployed();
        // await _VRFv2Consumer.setContractAddress(accounts[0]);
        let {tx, receipt} = await _VRFv2Consumer.requestRandomWords();
        blockNumber = tx.receipt.blockNumber;
        let events = receipt.logs
        expect(events.length).to.equal(1);
        requestId = events[0].data.substring(0, 66);
    })

    it("should return random number", async () => {
        let _VRFv2Consumer = await VRFv2Consumer.deployed();
        let events;
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
        expect(events.length).to.greaterThan(0)
        let random = await _VRFv2Consumer.getRandom.call(requestId);
        expect(Number(random)).not.eq(0)
    })
})

async function sleep(ms) {
    return new Promise(r => setTimeout(r, ms))
}