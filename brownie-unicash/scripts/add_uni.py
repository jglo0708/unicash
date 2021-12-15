from brownie import StoreCharity, accounts
from scripts.helpful_scripts import get_account
import shutil
import os
import json

STORE = "0x3194cBDC3dbcd3E11a07892e7bA5c3394048Cc87"


STORE = "0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6"

UNIVERSITIES = [
    ["Bocconi", accounts[5]],
    ["Standford", accounts[6]],
    ["Harvard", accounts[7]],
]


def add_uni(store, uni):

    store.NewUni(uni[0], {"from": uni[1]})


def main():
    store = StoreCharity.at(STORE)
    for uni in UNIVERSITIES:
        add_uni(store, uni)
