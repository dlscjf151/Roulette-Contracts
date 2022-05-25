//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VRFv2Consumer is VRFConsumerBaseV2, Ownable {
    VRFCoordinatorV2Interface COORDINATOR;

    // VRF subscription ID.
    uint64 private _subscriptionId;

    // Fuji coordinator
    address private _vrfCoordinator = 0x2eD832Ba664535e5886b75D64C46EB9a228C2610;

    // The gas lane to use, which specifies the maximum gas price to bump to
    bytes32 private _keyHash = 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas,
    // so 100,000 is a safe default for this example contract. Test and adjust
    // this limit based on the network that you select, the size of the request,
    // and the processing of the callback request in the fulfillRandomWords()
    // function.
    uint32 private _callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 private _requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 private _numWords = 1;

    // requestId => randomWord
    mapping(uint256 => uint256) private _randomWords;

    address private _contractAddress;

    modifier onlyContract() {
        require(msg.sender == _contractAddress);
        _;
    }

    constructor(uint64 subscriptionId) VRFConsumerBaseV2(_vrfCoordinator) {
        COORDINATOR = VRFCoordinatorV2Interface(_vrfCoordinator);
        _subscriptionId = subscriptionId;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external onlyContract returns (uint256){
        // Will revert if subscription is not set and funded.
        uint256 requestId = COORDINATOR.requestRandomWords(
            _keyHash,
            _subscriptionId,
            _requestConfirmations,
            _callbackGasLimit,
            _numWords
        );
        return requestId;
    }

    function getRandom(uint256 requestId) public view returns (uint256){
        return _randomWords[requestId];
    }

    function setContractAddress(address contractAddress) public onlyOwner {
        _contractAddress = contractAddress;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        _randomWords[requestId] = randomWords[0];
    }
}
