from solcx import compile_standard

with open("./coin.sol", "r") as file:
    solidity_file = file.read()

compiled_solidity = compile_standard(solidity_file)