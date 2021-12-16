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
    
    AggregatorV3Interface internal priceFeed;

    mapping(address => uint256) public donations_to_this_contract; //mapping from donor to donation amount
    address[] public listOfDonors;

    using SafeMath for uint256;

    constructor(
        address payable _uni_address,
        string memory _description,
        address payable _store_address
        
    ) public {
        priceFeed = AggregatorV3Interface(0x9326BFA02ADD2366b30bacB125260Af641031331);
        owner = msg.sender;
        uni_address = _uni_address;
        store_address = _store_address;
        StoreCharity(address(_store_address)).NewContract(
            payable(msg.sender),
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
        require(_value> 0 wei, "You cannot donate 0");
        require(msg.sender.balance >= _value);
        donations_to_this_contract[msg.sender] += _value;
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
        StoreCharity(address(store_address)).DeleteContract(address(this)); //deletin the contract for the front end
        _destroyToken();
    }

    function _destroyToken() private {
        selfdestruct(payable(uni_address));
    }


    function _sendBackMoney() external {
        for (uint256 i = 0; i < listOfDonors.length; i++) {
            address payable to = payable(listOfDonors[i]);
            (bool success, ) = to.call{value: donations_to_this_contract[to]}("");
            require(success, "External Transfer Failed");
        }
        _destroyToken();
    }

    
    function getPrice() public view returns (int) {
        //(,int256 price,,,) = priceFeed.latestRoundData();
        //return uint256(price);
        (
            uint80 roundID, 
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();
        return price;
    }
    
    
    function getConversionRate(uint256 _amount) public view returns (uint256){
        uint256 _newInput = _amount * 10 ** 8;
        //uint256 ethAmountInUsd = _newInput / getPrice();
        return _newInput;//ethAmountInUsd;
    }

    function checkContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

