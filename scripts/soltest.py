import json
from web3 import Web3

# Connect to local Ethereum node (e.g., Ganache)
w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

# Check if connected to the node
if not w3.isConnected():
    raise Exception("Unable to connect to Ethereum node")

# Set default account (e.g., account[0] in Ganache)
w3.eth.default_account = w3.eth.accounts[0]

# Contract ABI (replace with your contract's ABI)
abi = json.loads('''[
    {
        "inputs": [],
        "stateMutability": "payable",
        "type": "constructor"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "from",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "Received",
        "type": "event"
    },
    {
        "anonymous": false,
        "inputs": [
            {
                "indexed": true,
                "internalType": "address",
                "name": "to",
                "type": "address"
            },
            {
                "indexed": false,
                "internalType": "uint256",
                "name": "amount",
                "type": "uint256"
            }
        ],
        "name": "Sent",
        "type": "event"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_address",
                "type": "address"
            }
        ],
        "name": "addAddress",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "checkFunds",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "getAuthorizedAddresses",
        "outputs": [
            {
                "internalType": "address[]",
                "name": "",
                "type": "address[]"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "nonce",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address",
                "name": "_address",
                "type": "address"
            }
        ],
        "name": "removeAddress",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address payable",
                "name": "_to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_amount",
                "type": "uint256"
            }
        ],
        "name": "sendFunds",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [
            {
                "internalType": "address payable",
                "name": "_to",
                "type": "address"
            },
            {
                "internalType": "uint256",
                "name": "_amount",
                "type": "uint256"
            },
            {
                "internalType": "uint256",
                "name": "_nonce",
                "type": "uint256"
            },
            {
                "internalType": "bytes",
                "name": "signature",
                "type": "bytes"
            }
        ],
        "name": "sendFundsWithSignature",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
    },
    {
        "inputs": [],
        "name": "owner",
        "outputs": [
            {
                "internalType": "address",
                "name": "",
                "type": "address"
            }
        ],
        "stateMutability": "view",
        "type": "function"
    }
]''')

# Contract bytecode (replace with your contract's bytecode)
bytecode = '0x...'

# Deploy the contract
MyContract = w3.eth.contract(abi=abi, bytecode=bytecode)
tx_hash = MyContract.constructor().transact()
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
contract_address = tx_receipt.contractAddress

# Create contract instance
my_contract = w3.eth.contract(address=contract_address, abi=abi)

# Check initial owner
owner = my_contract.functions.owner().call()
print(f"Contract owner: {owner}")

# Add an authorized address
tx_hash = my_contract.functions.addAddress(w3.eth.accounts[1]).transact()
w3.eth.wait_for_transaction_receipt(tx_hash)

# Verify the authorized address
authorized_addresses = my_contract.functions.getAuthorizedAddresses().call()
print(f"Authorized addresses: {authorized_addresses}")

# Check contract balance
balance = my_contract.functions.checkFunds().call()
print(f"Contract balance: {balance}")

# Send funds (without signature for testing purposes)
tx_hash = my_contract.functions.sendFunds(w3.eth.accounts[2], w3.toWei(1, 'ether')).transact({'value': w3.toWei(1, 'ether')})
w3.eth.wait_for_transaction_receipt(tx_hash)

# Verify the new balance
balance = my_contract.functions.checkFunds().call()
print(f"Contract balance after sending: {balance}")

# Additional steps to test `sendFundsWithSignature` would involve generating a valid signature from the owner's private key.
