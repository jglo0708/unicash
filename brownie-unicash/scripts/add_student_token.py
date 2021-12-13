from brownie import StoreCharity, TokenUni, network, config, accounts
from scripts.helpful_scripts import get_account, get_contract
import shutil
import os
import yaml
import json
from web3 import Web3
import argparse


# KEPT_BALANCE = Web3.toWei(100, "ether")


def create_student_token(owner, uni_address, store, description):
    student_token = TokenUni.deploy(uni_address, description, store, {"from": owner})
    #
    # if update_front_end_flag:
    # update_front_end()
    return student_token


def main():
    # parser = argparse.ArgumentParser(description='Add a Student Coin')

    # parser.add_argument('--student')
    # parser.add_argument('--uni',)
    # parser.add_argument('--description',)
    # parser.add_argument('--store_address',)

    # args = parser.parse_args()

    student = get_account(1)
    uni_address = get_account(2)
    store_address = "0x602C71e4DAC47a042Ee7f46E0aee17F94A3bA0B6"
    description = "Bocconi"
    create_student_token(student, uni_address, store_address, description)
    # create_student_token(args.student, args.uni_address, args.store_address, args.description)
