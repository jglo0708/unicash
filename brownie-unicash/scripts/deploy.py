from brownie import StoreCharity, TokenUni, network, config, accounts
import shutil
import os
import yaml
import json
import time

# from web3 import Web3
# from random import randint, seed
import random
import time

STORE = accounts[0]

UNIVERSITIES = [
    ["Bocconi", accounts[1]],
    ["Standford", accounts[2]],
    ["Harvard", accounts[3]],
    ["Politecnico", accounts[4]],
]

DONORS = [
    ["Jeff", accounts[5]],
    ["Elon", accounts[6]],
    ["Richard", accounts[7]],
]

STUDENTS = [
    accounts[8],
    accounts[9],
]

DESCRIPTIONS = [
    "Need funding for {} USD".format(random.randint(1000, 10000)),
    "Looking to collect money for Uni",
    "Looking to funding",
    "Poor student",
    "Collection goal:{}".format(random.randint(200000, 1000000)),
]


def deploy_store(account):
    store_charity = StoreCharity.deploy(
        {"from": account},
    )
    return store_charity


def create_student_offers(students, universities, descriptions):
    student_uni_descriptions = []
    for student in students:
        no_of_offers = random.randint(1, 4)
        for offer in range(no_of_offers):
            uni = universities[random.randint(0, len(universities) - 1)][1]
            desc = descriptions[random.randint(0, len(descriptions) - 1)]
            student_uni_descriptions.append([student, uni, desc])
    return student_uni_descriptions


def add_Unis(store, universities):
    for uni in universities:
        store.NewUni(uni[0], {"from": uni[1]})


def add_Donors(store, donors):
    for donor in donors:
        store.NewDonor(donor[0], {"from": donor[1]})


def create_student_token(store, student_offer):
    student_token = TokenUni.deploy(
        student_offer[1], student_offer[2], store, {"from": student_offer[0]}
    )
    return student_token


def create_unis_donors(store):
    add_Unis(store, UNIVERSITIES)
    add_Donors(store, DONORS)


def validate_student_tokens(token, uni):
    random_number = random.random()
    if random_number > 0.01:  # basic way for not all getting their unis confirmed
        token.validate({"from": uni[1]})


def make_donation(token, donor):
    amt = random.randint(1, 1000)
    tx = token.Donate(amt, {"from": donor[1]})
    tx.wait(1)


def choosing_uni(token, student):
    token.chooseThisUni({"from": student})


def uni_withdraw(token, uni):
    tx = token.withdraw({"from": uni[1]})
    tx.wait(1)


def main():
    store = deploy_store(STORE)
    create_unis_donors(store)
    offers = create_student_offers(STUDENTS, UNIVERSITIES, DESCRIPTIONS)

    for offer in offers[:1]:
        val_tokens = []
        val_unis = []
        student = offer[0]
        token = create_student_token(store, offer)
        for uni in UNIVERSITIES:
            try:
                validate_student_tokens(token, uni)
                val_tokens.append(token)
                val_unis.append(uni)
            except:
                continue
        for donor in DONORS:
            try:
                make_donation(token, donor)
            except:
                continue

        assert len(val_tokens) == len(val_unis)

        try:
            random_int = random.randint(0, len(val_tokens) - 1)
            choosing_uni(val_tokens[random_int], student)
            uni_withdraw(val_tokens[random_int], val_unis[random_int])
        except:
            continue
