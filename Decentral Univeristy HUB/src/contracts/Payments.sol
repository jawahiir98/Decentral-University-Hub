pragma solidity ^0.5.0;

import './Tokens.sol';

contract Payments{
    address canteen;
    address shop01;
    address owner;

    Tokens public tokens;

    mapping (address => bool) public userIsRegsitered;

    event Paid(
        address indexed _payer,
        address indexed _receipient,
        uint256 indexed _amount,
        string  _type  // Type of payment -> is it food in the  
                              // 1. canteen     2. Library      3. Library
                              // 4. Inter-user transactions     5. Others
                              
    );

    modifier OnlyRegisteredUsers() {
        require(userIsRegsitered[msg.sender], 'User is not registered');
        _;
    }
    modifier IsSufficient(uint256 val){
        require(tokens.getBalance(msg.sender) >= val);
        _;
    }

    constructor (address _canteen, address _shop01, address _tokenAddress) public{
        canteen = _canteen;
        shop01 = _shop01;
        owner = msg.sender;
        tokens = Tokens(_tokenAddress);
    }

    function payTuitionFees(uint256 amount) public OnlyRegisteredUsers {
        require(tokens.getBalance(msg.sender) >= amount, 'Insufficient Funds');
        tokens.transferFrom(msg.sender, owner, amount);
        emit Paid(msg.sender, owner, amount, 'Tuition Fees');
    }

    function payTuitionFees(uint256 amount, address receiver) public OnlyRegisteredUsers {
        require(tokens.getBalance(msg.sender) >= amount, 'Insufficient Funds');
        tokens.transferFrom(msg.sender, receiver, amount);
        emit Paid(msg.sender, receiver, amount, 'Inter-user transactions');
    }
}