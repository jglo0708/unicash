from brownie import StoreCharity, TokenUni, network, config, accounts
from scripts.helpful_scripts import get_account, get_contract
import shutil
import os
import yaml
import json
from web3 import Web3
# from random import randint, seed
import random

STORE = accounts[0]

UNIVERSITIES = [
    ["Bocconi", accounts[1]],
    ["Standford", accounts[2]],
    ["Harvard", accounts[3]],
    ["Politecnico", accounts[4]],

]

DONORS = [
    ["Jeff",  accounts[5]],
    ["Elon",  accounts[6]],
    ["Richard", accounts[7]],
]

STUDENTS = [
    accounts[8],
    accounts[9],
]

DESCRIPTIONS = [
    "Need funding for {} USD".format(random.randint(1000,10000)),
    "Looking to collect money for Uni",
    "Looking to funding",
    "Poor student",
    "Collection goal:{}".format(random.randint(200000,1000000)),
]

def deploy_store(account):
    store_charity = StoreCharity.deploy({"from": account},)
    return store_charity

def create_student_offers(students, universities, descriptions):
    student_uni_descriptions = []
    for student in students:
        no_of_offers = random.randint(1,4)
        for offer in range(no_of_offers):
            uni = universities[random.randint(0, len(universities)-1)][1]
            desc = descriptions[random.randint(0, len(descriptions)-1)]
            student_uni_descriptions.append([student, uni, desc])
    return student_uni_descriptions


def add_Unis(store, universities):
    for uni in universities:
        store.NewUni(uni[0],{"from": uni[1]})

def add_Donors(store,donors):
    for donor in donors:
        store.NewDonor(donor[0],{"from": donor[1]})


def create_student_token(store, student_offer):
    return TokenUni.deploy(student_offer[1], student_offer[2], store, {"from": student_offer[0]})


def create_unis_donors(store):
    add_Unis(store, UNIVERSITIES)
    add_Donors(store, DONORS)


def validate_student_tokens(token, unis):
    for uni in unis:
        try:
            if random.random()>0.1: #basic way for not all getting their unis confirmed
                token.validate({"from": uni[1]})
            else:
                continue
        except:
            continue


def make_donation(token, donor):
    amt = random.randint(1, 1000)
    print(amt)
    token.Donate(amt, {"from":donor[1]})



def update_front_end():
    print("Updating front end...")
    # The Build
    copy_folders_to_front_end("./build/contracts", "./front_end/src/chain-info")

    # The Contracts
    copy_folders_to_front_end("./contracts", "./front_end/src/contracts")

    # The ERC20
    copy_files_to_front_end(
        "./build/contracts/dependencies/OpenZeppelin/openzeppelin-contracts@4.3.2/ERC20.json",
        "./front_end/src/chain-info/ERC20.json",
    )
    # The Map
    copy_files_to_front_end(
        "./build/deployments/map.json",
        "./front_end/src/chain-info/map.json",
    )

    # The Config, converted from YAML to JSON
    with open("brownie-config.yaml", "r") as brownie_config:
        config_dict = yaml.load(brownie_config, Loader=yaml.FullLoader)
        with open(
            "./front_end/src/brownie-config-json.json", "w"
        ) as brownie_config_json:
            json.dump(config_dict, brownie_config_json)
    print("Front end updated!")


def copy_folders_to_front_end(src, dest):
    if os.path.exists(dest):
        shutil.rmtree(dest)
    shutil.copytree(src, dest)


def copy_files_to_front_end(src, dest):
    if os.path.exists(dest):
        shutil.rmtree(dest)
    shutil.copyfile(src, dest)

def main():
    store = deploy_store(STORE)
    create_unis_donors(store)
    offers = create_student_offers(STUDENTS, UNIVERSITIES, DESCRIPTIONS)
    for offer in offers:
        token = create_student_token(store, offer)
        validate_student_tokens(token, UNIVERSITIES)
        for donor in DONORS:
            try:
                make_donation(token, donor)
            except:
                continue

    