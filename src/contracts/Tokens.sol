pragma solidity ^0.5.0;

contract Tokens{
    string public name = 'AiubVerse';
    string public symbol = 'BDT';
    uint256 public totalSupply = 10**24; // 1 Million tokens (10^24)
    uint8 public decimals = 18;
    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor() public{
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }

    event Transfer (
        address indexed _from,
        address indexed _to,
        uint _value
    );

    event Approval (
        address indexed _owner,
        address indexed _spender,
        uint _value
    );
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    // Query -> Get Balance, Name, Symbol, Total Supply && Decimal
    function getBalance(address add)public view returns(uint256 smth) {
        return balanceOf[add];
    }
    // transfer function
    function transfer(address _to, uint256 _value) public returns(bool success){
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approval function
    function approve(address _spender,uint256 _value) public returns(bool success){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Smart contract retrieve tokens to transfer '_from' address to '_to' address fucntion
    function transferFrom(address _from,address _to,uint256 _value) public returns(bool success){
        require(balanceOf[_from] >= _value);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        if(!approve(_from, _value)) return false;
        allowance[msg.sender][_from] -= _value;
        emit Transfer((_from), _to, _value);
        return true;
    }
    // Only owner shall be able to mint (create and deploy tokens to network)
    function mint(address receiver, uint256 _amount) public onlyOwner(){
        balanceOf[receiver] += _amount;
        totalSupply += _amount;
    }
    // Only owner shall be able to burn (demolish from the network)
    function burn(uint256 amount) public onlyOwner() {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance to burn");
        balanceOf[msg.sender] -= amount;
        totalSupply -= amount;
    }
}