// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract myContract
{
    // Owner address
    address public owner;
    // Number used only once to be incremented for signatures
    uint256 nonce;

    // Constructor function to set the owner of the contract
    constructor() payable
    {
        // Set the owner of the contract to the deployer address
        owner = msg.sender;
        // Init nonce
        nonce = 0;
    }

    // Events for receiving and sending funds 
    event Received(address indexed from, uint256 amount);
    event Sent(address indexed to, uint256 amount);

    // Authorized addresses that can send funds to any recipient
    address[] private authorizedAddresses;

    // Mapping to store the index of each authorized address in the array for O(1) removal
    mapping(address => uint) public authorizedAddressIndex;

    // Modifiers for owner and authorized
    modifier onlyOwner
    {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    modifier onlyAuthorized
    {
        require(isAuthorized(msg.sender), "Not authorized");
        _;
    }

    // Helper function for authorization
    function isAuthorized(address _address) private view returns(bool)
    {
        // Owner should return true even though it's already checked in onlyOwner
        if(_address == owner)
        {
            return true;
        }
        // Checks if the address is in the map of addressIndexes
        else if(authorizedAddressIndex[_address] != 0)
        {
            return true;
        }
        // Checks if it's the first entered address since the mapping before doesn't check this
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
        require(!isAuthorized(_address), "Address is already authorized");
        // Assign the index to the length of the list at the time of addition
        authorizedAddressIndex[_address] = authorizedAddresses.length;
        // Push the new address
        authorizedAddresses.push(_address);
    }

    function removeAddress(address _address) public onlyOwner
    {
        require(isAuthorized(_address), "Address is not authorized");
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
    function getAuthorizedAddresses() public view returns (address[] memory)
    {
        return authorizedAddresses;
    }

    // Receive funds and emit an event
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

    // Simple send without signing to test on testnet using MetaMask wallet
    function sendFunds(address payable _to, uint _amount) public onlyAuthorized
    {
        // Check balance first
        require(address(this).balance >= _amount, "Insufficient balance");
        _to.transfer(_amount);
        emit Sent(_to, _amount);
    }

    // Function to sendFunds with a signature as stated per task
    function sendFundsSigned(address payable _to, uint _amount, bytes memory _signature) external payable onlyAuthorized returns (bool) 
    {
        // Check balance first
        require(address(this).balance >= _amount, "Insufficient balance");

        // Create the message hash
        bytes32 messageHash = getMessageHash(abi.encodePacked(msg.sender, _to, _amount, nonce));
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        // Verify the signature
        require(recover(ethSignedMessageHash, _signature) == msg.sender, "Invalid signature");

        // Increment the nonce to avoid replay attacks
        nonce++;

        // Transfer the amount
        _to.transfer(_amount);

        emit Sent(_to, _amount);
        return true;
    }

    // Verify to check signature
    function verify(address _signer, bytes memory _message, bytes memory _sig) external pure returns (bool)
    {
        bytes32 messageHash = getMessageHash(_message);
        bytes32 ethSignedMessageHash = getEthSignedMessageHash(messageHash);

        return recover(ethSignedMessageHash, _sig) == _signer;
    }

    function getMessageHash(bytes memory _message) public pure returns (bytes32)
    {
        return keccak256(_message);
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32)
    {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _messageHash));
    }

    function recover(bytes32 _ethSignedMessageHash, bytes memory _sig) public pure returns (address)
    {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns (bytes32 r, bytes32 s, uint8 v)
    {
        require(_sig.length == 65, "Invalid signature length");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }

}
