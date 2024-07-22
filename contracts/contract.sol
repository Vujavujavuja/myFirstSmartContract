// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract myContract
{
    // Owner address
    address public owner;

    // Constructor function to set the owner of the contract
    constructor() payable
    {
        // Set the owner of the contract to the deployer address
        owner = msg.sender;
    }

    // Events for receiving and sending funds 
    event Received (address indexed from, uint amount);
    event Sent(address indexed to, uint amount);

    // Authorized addresses that can send funds to any recipient
    address[] private authorizedAddresses;

    // Mapping to store the index of each authorized address in the array for O(1) removal
    mapping(address => uint) public authorizedAddressIndex;

    // Modifiers for owner and authorized
    modifier onlyOwner
    {
        require(msg.sender == owner);
        _;
    }

    modifier onlyAuthorized
    {
        require(isAuthorized(msg.sender));
        _;
    }

    // Helper function for authorization
    function isAuthorized(address _address) private view returns(bool)
    {
        // Owner should return true even though its already checked in onlyOwner
        if(_address == owner)
        {
            return true;
        }
        // Checks if the address is in the map of adressIndexes
        else if(authorizedAddressIndex[_address] != 0)
        {
            return true;
        }
        // Checks if its the first entered address since the mapping before doesnt check this
        else if(authorizedAddresses.length > 0 && authorizedAddresses[0] == _address)
        {
            return true;
        }
        return false;
    }

    // Adding and removing addresses from authorizedAddresses (ONLY OWNER)
    function addAddress(address _address) public onlyOwner
    {
        // Check if the address is already authorized
        require(!isAuthorized(_address));
        // Assign the index to the length of the list at the time of addition
        authorizedAddressIndex[_address] = authorizedAddresses.length;
        // Push the new address
        authorizedAddresses.push(_address);
    }

    function removeAddress(address _address) public onlyOwner
    {
        require(isAuthorized(_address));
        uint index = authorizedAddressIndex[_address];
        uint lastIndex = authorizedAddresses.length - 1;
        address lastAddress = authorizedAddresses[lastIndex];

        // Swap last with the one being removed
        authorizedAddresses[index] = lastAddress;
        authorizedAddressIndex[lastAddress] = index;

        authorizedAddresses.pop();
        delete authorizedAddressIndex[_address];
    }

    // For debugging and checking if addresses are added and removed properly
    function getAuthorizedAddresses() public view returns (address[] memory) {
        return authorizedAddresses;
    }

    // Recieve funds and emit an event
    receive() external payable 
    {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable 
    { 
        emit Received(msg.sender, msg.value);
    }

    // Debugging function checkFunds to check if funds are going in and out properly
    function checkFunds() public view returns (uint)
    {
        return address(this).balance;
    }


    // Simple send without singing to test on testnet using MetaMask wallet
    function sendFunds(address payable _to, uint _amount) public onlyAuthorized
    {
        require(address(this).balance >= _amount);
        _to.transfer(_amount);
        emit Sent(_to, _amount);
    }

}