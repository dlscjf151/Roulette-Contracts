//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./VRFv2Consumer.sol";

contract Roulette is Ownable {

    using SafeMath for uint256;

    struct State {
        address player;     // player's address
        bool isBetting;     // status if betting
        uint256 betAmount;  // bet amount
        uint256 betNumber;  // selected number
        uint256 requestId;  // request id for vrf
    }

    mapping(address => State) private _states;
    VRFv2Consumer private _VRFv2Consumer;
    uint256 constant private BET_UNIT = 0.0001 ether;
    uint256 constant private MAX = 2;
    uint256 private _withdrawableAmount;

    event Bet(address indexed player, uint256 betAmount, uint256 betNumber, uint256 requestId);
    event Reveal(address indexed player, uint256 betNumber, uint256 randomNumber, uint256 betAmount, uint256 prize);

    constructor(address VRFv2ConsumerAddress){
        _VRFv2Consumer = VRFv2Consumer(VRFv2ConsumerAddress);
    }

    receive() external payable {
        _withdrawableAmount = _withdrawableAmount.add(msg.value);
    }

    fallback() external payable {}

    function isBetting() external view returns (bool){
        return _states[msg.sender].isBetting;
    }

    function withdraw() external onlyOwner {
        address owner_ = owner();
        payable(owner_).transfer(_withdrawableAmount);
        _withdrawableAmount = 0;
    }

    function bet(uint256 number) public payable {
        require(msg.value.mod(BET_UNIT) == 0, "Roulette: value is invalid");
        require(!_states[msg.sender].isBetting, "Roulette: you already bet");
        require(0 < number && number <= MAX, "Roulette: selected number is out of range");
        uint256 requestId;
        requestId = _VRFv2Consumer.requestRandomWords();

        _states[msg.sender].player = msg.sender;
        _states[msg.sender].isBetting = true;
        _states[msg.sender].betAmount = msg.value;
        _states[msg.sender].betNumber = number;
        _states[msg.sender].requestId = requestId;

        emit Bet(msg.sender, msg.value, number, requestId);
    }

    function reveal() public {
        require(_states[msg.sender].isBetting, "Roulette: you did not bet yet");

        uint256 requestId = _states[msg.sender].requestId;
        uint256 random = _VRFv2Consumer.getRandom(requestId);

        require(random != 0, "Roulette: game does not finished yet");

        uint256 randomRanged = random.mod(MAX).add(1);
        uint256 prize = 0;
        if (randomRanged == _states[msg.sender].betNumber) {
            prize = _states[msg.sender].betAmount.mul(3).div(2);
            payable(_states[msg.sender].player).transfer(prize);
        }
        else {
            _withdrawableAmount = _withdrawableAmount.add(_states[msg.sender].betAmount);
        }

        emit Reveal(_states[msg.sender].player, _states[msg.sender].betNumber, randomRanged, _states[msg.sender].betAmount, prize);

        _states[msg.sender].player = address(0);
        _states[msg.sender].betNumber = 0;
        _states[msg.sender].isBetting = false;
        _states[msg.sender].betAmount = 0;
        _states[msg.sender].requestId = 0;
    }
}
