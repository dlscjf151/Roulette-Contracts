const VRFv2Consumer = artifacts.require('VRFv2Consumer');

module.exports = function(deployer, network, accounts){
    deployer.deploy(VRFv2Consumer, 74).then(_VRFv2Consumer => _VRFv2Consumer.setContractAddress(accounts[0]))
}