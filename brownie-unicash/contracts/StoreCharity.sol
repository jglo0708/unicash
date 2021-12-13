// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

import "OpenZeppelin/openzeppelin-contracts@3.1.0/contracts/access/Ownable.sol";
import "OpenZeppelin/openzeppelin-contracts@3.1.0/contracts/math/SafeMath.sol";
import "./TokenUni.sol";

// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

contract StoreCharity {
    address owner; //owner of the address (not particulary useful at the moment)
    uint256 public contracts = 0; //number of users (students issuing CharityToken)
    mapping(address => bool) public contracts_validated; //which contracts have been validated by unis
    mapping(address => mapping(address => uint256)) donations_per_contracts;
    mapping(address => Contract) public contracts_store; //address is a contract address (because 1 student can have more than 1 address
    mapping(address => address[]) private _store_repayment; //mapping from student to his/her contacts which map to a bool telling if chosen
    address[] private _listOfDonors;
    address[] private _listOfUnis;
    address[] private _listOfContracts;

    struct Contract {
        address payable student_address;
        address payable uni_address;
        string description;
    }

    mapping(address => Donor) public donors_store;
    uint256 public donors = 0;
    uint256 initial_CharityTokens_donated = 0;

    struct Donor {
        //student class
        string description; //"I am This Guy" / "This company"
        uint256 charity_token_donated; //tokens issued
    }

    mapping(address => University) public uni_store;
    uint256 public universities = 0;

    struct University {
        string uni_name;
    }

    using SafeMath for uint256;

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
    }

    function NewDonor(string memory _description) public {
        donors++; //increase the number of users
        donors_store[msg.sender] = Donor(
            _description,
            initial_CharityTokens_donated
        ); //initialize the Donor
        _listOfDonors.push(msg.sender);
    }

    function NewUni(string memory _uni_name) public {
        universities++;
        uni_store[msg.sender] = University(_uni_name);
        _listOfUnis.push(msg.sender);
    }

    function StoreValidation() external {
        contracts_validated[msg.sender] = true;
    }

    function StoreDonation(uint256 _value) external {
        donations_per_contracts[tx.origin][msg.sender] += _value;
        donors_store[tx.origin].charity_token_donated += _value;
    }

    function StoreChoices(address _student_address) external {
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
                    ._sendBackMoney();
            } else {}
        }
    }

    function checkContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
