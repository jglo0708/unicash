from brownie import StoreCharity, TokenUni, network, config, accounts
from scripts.helpful_scripts import get_account, get_contract
import shutil
import os
import yaml
import json
from web3 import Web3


def create_student_token(owner, uni_address, store, description, *args):
    student_token = TokenUni.deploy(uni_address, description, store, {"from": owner})
    return student_token

UNIVERSITIES = [
    ["Bocconi", accounts[5]],
    ["Standford", accounts[6]],
    ["Harvard", accounts[7]],
]
STORE = '0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6'

def main():
    student = get_account(2)
    description = "Bocconi"
    create_student_token(student, UNIVERSITIES[0][1], STORE, description)

