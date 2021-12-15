// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.0;

import "OpenZeppelin/openzeppelin-contracts@3.1.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@3.1.0/contracts/math/SafeMath.sol";

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

import "./StoreCharity.sol";

contract TokenUni {
    address owner;
    address payable uni_address;
    address payable store_address;
    bool public met_criteria = false;
    bool public chosen = false;
    uint256 public sum_transfered = 0;

    mapping(address => uint256) public donations_to_this_contract; //mapping from donor to donation amount
    address[] public listOfDonors;

    using SafeMath for uint256;

    constructor(
        address payable _uni_address,
        string memory _description,
        address payable _store_address
    ) public {
        owner = msg.sender;
        uni_address = _uni_address;
        store_address = _store_address;
        StoreCharity(address(_store_address)).NewContract(
            msg.sender,
            _uni_address,
            _description
        );
    }

    function validate() external {
        //require only uni to do it
        require(msg.sender == uni_address, "Only Uni can validate");
        met_criteria = true;
        StoreCharity(address(store_address)).StoreValidation();
    }

    function Donate(uint256 _value) public payable {
        //require donor in donors_store in the big;
        require(met_criteria == true, "Uni has yet to validate this token");
        require(msg.value > 0 wei, "You cannot donate 0");
        require(msg.sender.balance >= msg.value);
        require(msg.value == _value, "values do not match");
        donations_to_this_contract[msg.sender] += msg.value;
        listOfDonors.push(msg.sender);
        StoreCharity(address(store_address)).StoreDonation(_value);
    }

    function chooseThisUni() public {
        require(met_criteria == true, "Uni did not verify the contract yet");
        require(msg.sender == owner, "Only the student can decide");
        chosen = true;
        StoreCharity(address(store_address)).StoreChoices(msg.sender);
    }

    function withdraw() external {
        require(chosen == true, "Student did not chose this uni yet");
        uint256 _amount = address(this).balance;
        (bool success, ) = uni_address.call{value: _amount}("");
        require(success, "External Transfer Failed");
        _destroyToken();
    }

    function _destroyToken() private {
        selfdestruct(payable(uni_address));
    }

    function getSumTransferedUsd() public returns (uint256) {
        return getConversionRate(sum_transfered);
    }

    function _sendBackMoney() external {
        for (uint256 i = 0; i < listOfDonors.length; i++) {
            address payable to = payable(listOfDonors[i]);
            sum_transfered += donations_to_this_contract[to];
            (bool success, ) = to.call{value: donations_to_this_contract[to]}(
                ""
            );
            require(success, "External Transfer Failed");
        }
        _destroyToken();
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }

    // 1000000000
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
    }

    function checkContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}