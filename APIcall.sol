// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/docs/link-token-contracts/
 */

contract APICall is ChainlinkClient {
    using Chainlink for Chainlink.Request;

    uint256 public exchange_rate;
    uint256 public test;
    bytes32 public name;
    bytes32 public requestid;
    string public latest_request;

    address private contractowner;
    address private oracle;
    bytes32 private jobId;
    uint256 private fee;

    /**
     * Network: Kovan
     * Oracle: 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8 (Chainlink Devrel
     * Node)
     * Job ID: d5270d1c311941d0b08bead21fea7747
     * Fee: 0.1 LINK
     */
    constructor(address _contractowner) {
        contractowner = _contractowner;
        setPublicChainlinkToken();
        oracle = 0xc57B33452b4F7BB189bB5AfaE9cc4aBa1f7a4FD8;
        jobId = "d5270d1c311941d0b08bead21fea7747";
        fee = 0.1 * 10**18; // (Varies by network and job)
    }

    /**
     * Create a Chainlink request to retrieve API response, find the target
     * data, then multiply by 1000000000000000000 (to remove decimal places from data).
     */
    function requestExchangeRate() public returns (bytes32 requestId) {
        require(msg.sender == contractowner);
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillexchange.selector
        );

        request.add(
            "get",
            "https://min-api.cryptocompare.com/data/price?fsym=ETH&tsyms=USD"
        );

        request.add("path", "USD");

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function requestUniData(string memory _domain)
        public
        returns (bytes32 requestId)
    {
        require(msg.sender == contractowner);
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfillexchange.selector
        );

        // Set the URL to perform the GET request on
        latest_request = concat_strings(
            "http://universities.hipolabs.com/search?domain=",
            _domain
        );
        request.add("get", latest_request);

        // Set the path to find the desired data in the API response, where the response format is:
        // [{"name": ..., ...}; ...]
        request.add("path", "0.name");

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function requestTestData() public returns (bytes32 requestId) {
        require(msg.sender == contractowner);
        Chainlink.Request memory request = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfilltest.selector
        );

        // Set the URL to perform the GET request on
        request.add("get", "https://jsonplaceholder.typicode.com/todos/1");

        // Set the path to find the desired data in the API response, where the response format is:
        // [{"name": ..., ...}; ...]
        // request.add("path", "0.name");
        request.add("path", "id");

        // Sends the request
        return sendChainlinkRequestTo(oracle, request, fee);
    }

    function concat_strings(string memory _stringa, string memory _stringb)
        internal
        pure
        returns (string memory req)
    {
        return string(abi.encodePacked(_stringa, _stringb));
    }

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

    /**
     * Receive the response in the form of uint256
     */
    function fulfillexchange(bytes32 _requestId, uint256 _name)
        public
        recordChainlinkFulfillment(_requestId)
    {
        requestid = _requestId;
        exchange_rate = _name;
    }

    function fulfilltest(bytes32 _requestId, uint256 _name)
        public
        recordChainlinkFulfillment(_requestId)
    {
        requestid = _requestId;
        test = _name;
    }

    function fulfill(bytes32 _requestId, bytes32 _name)
        public
        recordChainlinkFulfillment(_requestId)
    {
        requestid = _requestId;
        name = _name;
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}
