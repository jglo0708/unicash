from brownie import StoreCharity, TokenUni, network, config, accounts
from scripts.helpful_scripts import get_account, get_contract
import shutil
import os
import yaml
import json
from web3 import Web3
import argparse

STORE = "0x3194cBDC3dbcd3E11a07892e7bA5c3394048Cc87"

UNIVERSITIES = [
    {"Bocconi": accounts[5]},
    {"Standford": accounts[6]},
    {"Harvard": accounts[7]},
]


def add_uni(store, uni):
    store.NewUni(uni.key, {"from": uni.value})


def main():

    for uni in UNIVERSITIES:
        add_uni(STORE, uni)
