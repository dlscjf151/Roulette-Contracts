const Roulette = artifacts.require("Roulette");
const VRFv2Consumer = artifacts.require('VRFv2Consumer');

module.exports = async function (deployer) {
    let _VRFv2Consumer = await VRFv2Consumer.deployed()
    await deployer.deploy(Roulette, _VRFv2Consumer.address)
    let roulette = await Roulette.deployed();
    await _VRFv2Consumer.setContractAddress(roulette.address)
};
