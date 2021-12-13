// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.0;

import "OpenZeppelin/openzeppelin-contracts@3.1.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@3.1.0/contracts/math/SafeMath.sol";
import "contracts/StoreCharity.sol";

contract TokenUni {
    address owner;
    address payable uni_address;
    address payable store_address;
    bool public met_criteria = false;
    bool public chosen = false;

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

    function _sendBackMoney() external {
        for (uint256 i = 0; i < listOfDonors.length; i++) {
            address payable to = payable(listOfDonors[i]);
            (bool success, ) = to.call{value: donations_to_this_contract[to]}(
                ""
            );
            require(success, "External Transfer Failed");
        }
        _destroyToken();
    }

    function checkContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
