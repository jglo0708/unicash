from brownie import (
    accounts,
    network,
    config,
    Contract,
    # MockV3Aggregator,
)
import eth_utils


LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache"]


def get_account(index, id=None):
    if index:
        return accounts[index]
    # if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
    #     return accounts[]
    # if id:
    #     return accounts.load(id)
    # return accounts.add(config["wallets"]["from_key"])


# # initalizer=box.store, 1
# def encode_function_data(initializer=None, *args):
#     """Encodes the function call so we can work with an initializer.
#     Args:
#         initializer ([brownie.network.contract.ContractTx], optional):
#         The initializer function we want to call. Example: `box.store`.
#         Defaults to None.
#         args (Any, optional):
#         The arguments to pass to the initializer function
#     Returns:
#         [bytes]: Return the encoded bytes.
#     """
#     if len(args) == 0 or not initializer:
#         return eth_utils.to_bytes(hexstr="0x")
#     return initializer.encode_input(*args)


# def upgrade(
#     account,
#     proxy,
#     new_implementation_address,
#     proxy_admin_contract=None,
#     initializer=None,
#     *args,
# ):
#     transaction = None
#     if proxy_admin_contract:
#         if initializer:
#             encoded_function_call = encode_function_data(initializer, *args)
#             transaction = proxy_admin_contract.upgradeAndCall(
#                 proxy.address,
#                 new_implementation_address,
#                 encoded_function_call,
#                 {"from": account},
#             )
#         else:
#             transaction = proxy_admin_contract.upgrade(
#                 proxy.address, new_implementation_address, {"from": account}
#             )
#     else:
#         if initializer:
#             encoded_function_call = encode_function_data(initializer, *args)
#             transaction = proxy.upgradeToAndCall(
#                 new_implementation_address, encoded_function_call, {"from": account}
#             )
#         else:
#             transaction = proxy.upgradeTo(new_implementation_address, {"from": account})
#     return transaction


def get_contract(contract_name):
    """If you want to use this function, go to the brownie config and add a new entry for
    the contract that you want to be able to 'get'. Then add an entry in the in the variable 'contract_to_mock'.
    You'll see examples like the 'link_token'.
        This script will then either:
            - Get a address from the config
            - Or deploy a mock to use for a network that doesn't have it
        Args:
            contract_name (string): This is the name that is refered to in the
            brownie config and 'contract_to_mock' variable.
        Returns:
            brownie.network.contract.ProjectContract: The most recently deployed
            Contract of the type specificed by the dictonary. This could be either
            a mock or the 'real' contract on a live network.
    """
    contract_type = contract_to_mock[contract_name]
    if network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        if len(contract_type) <= 0:
            deploy_mocks()
        contract = contract_type[-1]
    else:
        try:
            contract_address = config["networks"][network.show_active()][contract_name]
            contract = Contract.from_abi(
                contract_type._name, contract_address, contract_type.abi
            )
        except KeyError:
            print(
                f"{network.show_active()} address not found, perhaps you should add it to the config or deploy mocks?"
            )
            print(
                f"brownie run scripts/deploy_mocks.py --network {network.show_active()}"
            )
    return contract

