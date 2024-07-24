# Smart Contract for Receiving and Sending Native Coins

## Overview

This repository contains a Solidity smart contract designed to handle receiving and sending native coins (ETH). The contract includes features for ownership management, authorized address management, and event emission upon receiving and sending funds. Additionally, the contract incorporates debugging and testing functions to demonstrate its functionality and the developer's thought process.

## Features

- **Receiving and Sending Funds:** The contract can receive and send native coins.
- **Event Emission:** Emits events when funds are received or sent.
- **Ownership Management:** Only the contract owner can authorize addresses to send funds.
- **Authorized Address Management:** Authorized addresses can be added and removed by the owner with O(1) complexity.
- **Security:** Ensures that only authorized addresses can transfer funds using the owner's signature.
- **Debugging Functions:** Includes functions to check funds and verify authorized addresses.
