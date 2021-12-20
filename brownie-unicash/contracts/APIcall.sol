// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.6/ChainlinkClient.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 */

contract APICall is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    // set the different public variables
    // echange rate variable can be fetched from here as well
    uint256 public exchange_rate;
    // test variable to check the validity of the oracle
    uint256 public test;
    // bytes32 of the latest university name
    string public name;
    // bytes32 to make sure the latest request was processed
    bytes32 public requestid;
    // string to see what was the latest requested university domain name
    string public latest_request;
    // variable to define the address of the only authorized user
    address private contractowner;
    // the next 3 values are dependent on the type of oracle and the network.
    // We use the Kovan test network and a general oracle that can query any API
    // the specification of the oracle addresses and JobIds can be found in the ChainLink documentation
    // address of the oracle to call for the job - set to private
    address private oracle;
    // ID of the job - set to private
    bytes32 private jobId;
    // amount to pay for the API query - set to private
    uint256 private fee;

    /**
     * Network: Kovan
     * Oracle: 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8 (Chainlink Devrel
     * Node)
     * Job ID: d5270d1c311941d0b08bead21fea7747
     * Fee: 0.1 LINK
     */
    constructor(address _contractowner) public {
        //set the authorized user when creating the contract
        contractowner = _contractowner;
        setPublicChainlinkToken();
        oracle = 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8;
        jobId = "d5270d1c311941d0b08bead21fea7747";
        fee = 0.1 * 10**18;
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestExchangeRate() public returns (bytes32 requestId) {
        // check autorized user
        require(msg.sender == contractowner);
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillexchange.selector
        );
        // setting the get request to get the ethereum to USD exchange rate
        request.add(
            "get",
            "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD"
        );
        // fetch the response path in the obtained json response
        request.add("path", "USD");

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function requestUniData(string memory _domain)
        public
        returns (bytes32 requestId)
    {
        // check autorized user
        require(msg.sender == contractowner);
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        // Set the URL to perform the GET request on by merging the base url and the specified domain name
        latest_request = concat_strings(
            "http://universities.hipolabs.com/search?domain=",
            _domain
        );
        // create the get request with the obtained url
        request.add("get", latest_request);

        // Set the path to find the desired data in the API response, where the response format is:
        // [{"name": ..., ...}; ...]
        // the API returns an array, domain name being unique, we take the first element of the array
        request.add("path", "0.name");

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function requestTestData() public returns (bytes32 requestId) {
        // check autorized user
        require(msg.sender == contractowner);
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfilltest.selector
        );

        // Set the URL to perform the GET request on, here a test API
        request.add("get", "https://jsonplaceholder.typicode.com/todos/1");

        // Set the path to find the desired data in the API response,
        // where the response format is simply an int variable in this case
        request.add("path", "id");

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    // function used to concatenate the strings to obtain the university url
    function concat_strings(string memory _stringa, string memory _stringb)
        internal
        pure
        returns (string memory req)
    {
        return string(abi.encodePacked(_stringa, _stringb));
    }

    // when having issues with the bytes32 format of the university API return,
    // an attempt was made to change the return into a string format.
    // This was unsuccessful. We do keep the function should it prove useful in a future solution
    // and because having the university name as string is convenient
    function bytes32ToString(bytes32 _bytes32)
        public
        pure
        returns (string memory)
    {
        uint8 i = 0;
        while (i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }

    // callback function to receive the exchange rate response in the form of uint256
    function fulfillexchange(bytes32 _requestId, uint256 _rate)
        public
        recordChainlinkFulfillment(_requestId)
    {
        requestid = _requestId;
        // we multiply the exchange rate by 1000000000000000000 to remove the decimals
        exchange_rate = _rate * 10**18;
    }

    // callback function to receive the test response in the form of uint256
    function fulfilltest(bytes32 _requestId, uint256 _test)
        public
        recordChainlinkFulfillment(_requestId)
    {
        requestid = _requestId;
        test = _test;
    }

    // callback function to receive the university response in the form of a bytes32
    // might want to implement the bytes_to_string function later on
    function fulfill(bytes32 _requestId, bytes32 _name)
        public
        recordChainlinkFulfillment(_requestId)
    {
        requestid = _requestId;
        name = bytes32ToString(_name);
    }
}
