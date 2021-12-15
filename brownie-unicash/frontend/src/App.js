import React, { Component } from 'react'
import Web3 from 'web3'
import './App.css'

import { STORE_CHARITY, STORE_CHARITY_ADDRESS } from './config.js'

class App extends Component {
  componentWillMount() {
    this.loadBlockchainData()
  }

  async loadBlockchainData() {
    const web3 = new Web3(Web3.givenProvider || "http://localhost:8545")
    const accounts = await web3.eth.getAccounts()
    this.setState({ account: accounts[0] })
    const storeCharity = new web3.eth.Contract(STORE_CHARITY, STORE_CHARITY_ADDRESS)
    this.setState({ storeCharity })
    // const contractsStore = storeCharity.methods.contracts_store().call()
    // this.setState({ contractsStore })
    // const uniStore = storeCharity.methods.uni_store().call()
    // this.setState({ uniStore })
    // const donorStore = storeCharity.methods.donors_store().call()
    // this.setState({ donorStore })
    }


  constructor(props) {
    super(props)
    this.state = { account: '' }
  }

  render() {
    const data =[{"name":"test1"},{"name":"test2"}];
    return (
      <div className="container">
        <h1>Hello, World!</h1>
        <p>Your account: {this.state.account}</p>
        {data.map(function(d, idx){
           return (<li key={idx}>{d.name}</li>)
          })}
          </div>
        );
      }
}

export default App;