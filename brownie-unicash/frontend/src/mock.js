import React, { useEffect, useState, Component } from 'react';
import Web3 from 'web3';
import { STORE_CHARITY_ADDRESS, STORE_CHARITY_ABI } from './config.js';

class App extends Component {
  componentWillMount() {
    this.loadBlockchainData()
  }

  async loadBlockchainData() {
    const web3 = new Web3(Web3.givenProvider || "http://localhost:8545")
    const accounts = await web3.eth.getAccounts()
    const store = new web3.eth.Contract(STORE_CHARITY_ABI,STORE_CHARITY_ADDRESS)
    this.setState({ store })
    const count = await store.methods.contracts().call()
    this.setState({ count })
    for (var i = 10; i <= 19; i++){ //iterate over student accounts
      const donation = await store.methods.total_donations_per_contract(accounts[i]).call()
      this.setState({
        donations: [...this.state.donations, donation]
      })
      const description = await store.contracts_descriptions.(accounts[i]).call()
      this.setState({
        donations: [...this.state.donations, description]
      })
    }
  }
  

  constructor(props) {
    super(props)
    this.state = {
      account: '',
      count: 101,
      donations: [],
      donations: [],
    }
}

render() {
  return (
    <div>
      <div className="container-fluid">
      <h2>Your account: {this.state.account}</h2> 
      <h1>Store Charity</h1> 
      <h2>Number of deployed contracts: {this.state.count}</h2> 
      
        <div className="row">
          <main role="main" className="col-lg-12 d-flex justify-content-center">
            <div id="content">
              <ul id="donationsList" className="list-unstyled">
                { this.state.donations.map((donations, key) => {
                  return(
                    <div key={key}>
                      <label>
                        <span className="content">{donations}</span>
                      </label>
                    </div>
                  )
                })}
              </ul>
            </div>
          </main>
        </div>
      </div>
    </div>
  );
}
}
export default App;