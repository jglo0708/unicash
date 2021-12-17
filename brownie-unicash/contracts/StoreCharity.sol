// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.1.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.1.0/contracts/math/SafeMath.sol";

import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "https://github.com/smartcontractkit/chainlink/blob/develop/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

import "./TokenUni.sol";

contract StoreCharity {
    mapping(address => bool) public contracts_validated; //which contracts have been validated by unis
    mapping(address => mapping(address => uint256)) donations_per_contracts;
    mapping(address => address[]) private _store_repayment; //mapping from student to his/her contacts which map to a bool telling if chosen
    mapping(address => uint256) public total_donations_per_contract; //total donations for front end dashboard
    mapping(address => string) public contracts_descriptions; //contarct description fot front end dashboard

    address[] private _listOfDonors; //list of all donors
    address[] private _listOfUnis; //list of all unis
    address[] private _listOfContracts; //list of all contracts

    using SafeMath for uint256;

    mapping(address => Contract) public contracts_store; //address is a contract address (because 1 student can have more than 1 address
    uint256 public contracts = 0; //number of users (students issuing CharityToken)

    //creating a structure to create student university contracts
    struct Contract {
        address payable student_address; //this is the student (eth address) who will execute the contract
        address payable uni_address; //this is the university (eth address) which the student will execute the contract with
        string description; //this is the name of the university
    }

    mapping(address => Donor) public donors_store; //donor has an adress
    uint256 public donors = 0; //we initialize with 0 donors
    uint256 initial_CharityTokens_donated = 0; //number of charity token donated

    //creating a structure to create donors
    struct Donor {
        string description; //"I am This Guy" / "This company"
        uint256 charity_token_donated; //tokens issued
    }

    mapping(address => University) public uni_store; //university has an adress
    uint256 public universities = 0; //we initialize with 0 universities

    //creating a structure to create universities
    struct University {
        string uni_name; //the university address
    }

    address owner; //owner of the address (not particulary useful at the moment)

    constructor() public {
        owner = msg.sender; //the guy who create the ontract becames the owner
    }

    function NewContract(
        address payable _student_address,
        address payable _uni_address,
        string memory _description
    ) external {
        //function to add a student
        uint256 _inside = 0;
        for (uint256 i = 0; i < _listOfUnis.length; i++) {
            if (_listOfUnis[i] == _uni_address) {
                _inside += 1;
            } else {
                _inside += 0;
            }
        }
        require(_inside == 1, "Uni not in the database");

        contracts++; //increase the number of users
        contracts_store[msg.sender] = Contract(
            _student_address,
            _uni_address,
            _description
        ); //initialize the contract
        _listOfContracts.push(msg.sender);
        _store_repayment[_student_address].push(msg.sender);
        contracts_descriptions[msg.sender] = _description; //insert the contract with the description inside the mapping for front end
    }

    //we define what happens when we create a new donor
    function NewDonor(string memory _description) public {
        donors++; //increase the number of users
        donors_store[msg.sender] = Donor(
            _description,
            initial_CharityTokens_donated
        ); //initialize the Donor
        _listOfDonors.push(msg.sender); //add donor to list of donors
    }

    //we define what happens when we create a new uni
    function NewUni(string memory _uni_name) public {
        universities++; //increase number of universities
        uni_store[msg.sender] = University(_uni_name); //initialize the uni
        _listOfUnis.push(msg.sender); //add uni to list of donors
    }

    //we define if the contracts are validated to the store
    function StoreValidation() external {
        contracts_validated[msg.sender] = true;
    }

    //we define what donations have been made to the store
    function StoreDonation(uint256 _value) external {
        donations_per_contracts[tx.origin][msg.sender] += _value;
        donors_store[tx.origin].charity_token_donated += _value;
        total_donations_per_contract[msg.sender] = address(msg.sender).balance; //change the amount of money donated insiede the mapping for front end
    }

    //we define the final choice made by the student
    function StoreChoices(address _student_address) external {
        if (_store_repayment[_student_address].length == 1) {} else {
            for (
                uint256 i = 0;
                i < _store_repayment[_student_address].length;
                i++
            ) {
                if (
                    TokenUni(address(_store_repayment[_student_address][i]))
                        .chosen() == false
                ) {
                    TokenUni(address(_store_repayment[_student_address][i]))
                        ._sendBackMoney(); //we send the money back to the other universities if that university is not chosen
                } else {}
            }
        }
    }

    //function to delete the contract inside the mapping for front end
    function DeleteContract(address _address) external {
        delete (total_donations_per_contract[_address]);
        delete (contracts_descriptions[_address]);
    }

    //function to check the balance in the contract
    function checkContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
