// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.1.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.1.0/contracts/math/SafeMath.sol";

import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

import "./StoreCharity.sol";

contract TokenUni {
    address owner; //this is the owner of the contract
    address payable uni_address; //this is the uni (eth address) who will execute the contract
    address payable store_address; //this is the store (eth address) who will execute the contract
    bool public met_criteria = false; //this is the initial value for the validation of a contract
    bool public chosen = false; //this is the initial value for which value was chosen

    mapping(address => uint256) public donations_to_this_contract; //mapping from donor to donation amount
    address[] public listOfDonors; //list of all donors for this contract

    using SafeMath for uint256;

    constructor(
        address payable _uni_address,
        string memory _description,
        address payable _store_address
    ) public {
        owner = msg.sender; //owner of the contract is the one who makes it
        uni_address = _uni_address;
        store_address = _store_address;
        StoreCharity(address(_store_address)).NewContract(
            payable(msg.sender),
            _uni_address,
            _description
        ); //store it in the store
    }

    //function for universities to validate that the student has received an offer
    function validate() external {
        //can double validate
        require(msg.sender == uni_address, "Only Uni can validate"); //require only uni to do it
        met_criteria = true; //approval that uni validates this contract
        StoreCharity(address(store_address)).StoreValidation(); //store it in the store
    }

    //function for donors to make donations
    function Donate(uint256 _value) public payable {
        //STILL NEED TO DO require donor in donors_store in the big;
        require(met_criteria == true, "Uni has yet to validate this token"); //we verify that this uni has validated the student
        require(_value > 0 wei, "You cannot donate 0"); //check that the donation amount is greater than 0
        require(msg.sender.balance >= _value); //check that the donors has the required funds
        donations_to_this_contract[msg.sender] += _value; //increase the amount donated to this contract
        listOfDonors.push(msg.sender); //add donor to list of donors
        StoreCharity(address(store_address)).StoreDonation(_value); //store it in the store
    }

    //function to choose a specific university
    function chooseThisUni() public {
        require(met_criteria == true, "Uni did not verify the contract yet"); //we verify that this uni has validated the student
        require(msg.sender == owner, "Only the student can decide"); //we check that this function can only be made by the student
        chosen = true; //initialize that this is the chosen university
        StoreCharity(address(store_address)).StoreChoices(msg.sender); //store it in the store
    }

    //function for the university to take the money out of the contract
    function withdraw() external {
        require(chosen == true, "Student did not chose this uni yet"); //we need the student to have chosen this uni
        uint256 _amount = address(this).balance; //check how much money is in the balance
        (bool success, ) = uni_address.call{value: _amount}("");
        require(success, "External Transfer Failed");
        StoreCharity(address(store_address)).DeleteContract(address(this)); //delete the contract for the front end
        _destroyToken();
    }

    //function to destroy the token once is it no longer valid
    function _destroyToken() private {
        selfdestruct(payable(uni_address));
    }

    //function used to send back money to all donors (depending on which university was chosen)
    function _sendBackMoney() external {
        for (uint256 i = 0; i < listOfDonors.length; i++) {
            //cycle through all the donors
            address payable to = payable(listOfDonors[i]);
            (bool success, ) = to.call{value: donations_to_this_contract[to]}(
                ""
            );
            require(success, "External Transfer Failed");
        }
        _destroyToken(); //at the end we destro the token
    }

    //function to get the price unsing chainlink
    function _getPrice() private view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            0x9326BFA02ADD2366b30bacB125260Af641031331
        );
        (, int256 answer, , , ) = priceFeed.latestRoundData(); //getting the price of one ETH to USD
        uint256 convertedAnswer = uint256(answer) * 10**10;
        return convertedAnswer;
    }

    //function to get the conversion rate
    function _getValueUsd(uint256 _amount) private view returns (uint256) {
        uint256 ethAmountInUsd = (_amount * _getPrice()) / (1 * 10**36);
        return ethAmountInUsd; //ethAmountInUsd;
    }

    function valueContractUsd() public view returns (uint256) {
        uint256 contractBalanceUsd = _getValueUsd(address(this).balance);
        return contractBalanceUsd;
    }

    //function to check the balance in the contract
    function checkContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
