// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.21;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBaseV2.sol";
import "./interfaces/IAuction.sol";

contract AuctionRandomizerVRF is VRFConsumerBaseV2 {
    error InvalidSender();

    event NumberPicked(uint256 indexed requestId, address indexed player);
    event NumberLanded(uint256 indexed requestId, uint256 indexed randomNumber);

    uint256 private constant OPERATION_IN_PROGRESS = 28;

    IAuction public auction;
    uint64 public subscriptionId;
    uint32 public callbackGasLimit = 40000;
    bytes32 public keyHash;
    address public vrfCoordinator;
    VRFCoordinatorV2Interface public COORDINATOR;
    uint16 public requestConfirmations = 3;
    uint32 public numWords =  1;

    mapping(uint256 => address) private players;
    mapping(address => uint256) private results;  

    constructor(
        uint64 _subscriptionId,
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        uint32 _numWords,
        IAuction _auction
    ) VRFConsumerBaseV2(_vrfCoordinator) {
        auction = IAuction(_auction);
        subscriptionId = _subscriptionId;
        callbackGasLimit = _callbackGasLimit;
        keyHash = _keyHash;
        vrfCoordinator = _vrfCoordinator;
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        requestConfirmations = _requestConfirmations;
        numWords = _numWords;
    }

    function pickNumber(address player) external returns (uint256 requestId) {
        if (msg.sender != address(auction)) revert InvalidSender();

        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );

        players[requestId] = player;
        results[player] = OPERATION_IN_PROGRESS;
        emit NumberPicked(requestId, player);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {
        uint256 randomNumber = randomWords[0] % 100 + 1; 

        results[players[requestId]] = randomNumber;

        emit NumberLanded(requestId, randomNumber);
    }
}