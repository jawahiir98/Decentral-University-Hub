pragma solidity ^0.5.0;

import  './Tokens.sol';

contract Payments {
    string public name = "AiubVerse";
    string public symbol = "BDT";
    uint256 public totalSupply = 10**24; // 1 Million tokens (10^24)
    uint8 public decimals = 18;
    address public owner;
    Tokens public tokens;
    
    // enum is 0 based index.
    enum Role {
        Student, 
        Admin, 
        Faculty, 
        ShopOwner,
        None
    }

    mapping (address => Role) public userRoles;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event SetRole(
        Role indexed _role,
        address indexed _address
    );
    event RemoveAdmin(
        address indexed _address
    );
    event TokenTransfer(
        address _from,
        address _to,
        uint256 amount
    );
    event TuitionFeesPayment(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    event PayAtLibrary(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    event PayAtShop(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
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
    event RemoveRole(
        address indexed _admin,
        address indexed _removed_address
    );

    constructor(Tokens _tokens) public{
        owner = msg.sender;
        tokens = _tokens;
        userRoles[owner] = Payments.Role.Admin;
        balanceOf[owner] = totalSupply;
    }

    
    // Create a list of Admins so that later on we can iterate over this list
    address [] AdminList;

    modifier onlyOwner(){
        if(msg.sender == owner)_;
    }
    /*
      RBAC (Role Based Access Control) implementation starts here...
    */
    function isAdmin(address _address) public view returns(bool admin){
        if(userRoles[_address] == Role.Admin) return true;
        return false;
    }
    modifier onlyAdmin() {
        if(isAdmin(msg.sender))_;
    }
    // Does user have a designated role ?
    function hasRole(address _address) public view returns(bool roleHave){
        if(userRoles[_address] != Role.None) return true;
        return false;
    }

    modifier onlyUser() {
        if(hasRole(msg.sender)) _;
    }
    // Set a role to a user by Admin
    function setRole(Role role, address _address) public onlyAdmin {
        require(_address != address(0), "Invalid address.");
        if(role == Role.Admin){
            require(msg.sender == owner, "Only owner can set admins.");
            userRoles[_address] = role;
            emit SetRole(role, _address);
            AdminList.push(_address);
        }
        else{
            userRoles[_address] = role;
            emit SetRole(role, _address);
        }
    }
    // Remove admin by owner
    function removeAdmin(address _address) public onlyOwner{
        require(_address != address(0), "Invalid address.");
        delete userRoles[_address];
        emit RemoveAdmin(_address);
    }
    // Admin can remove other roles.
    function removeRole(address _address) public onlyAdmin{
        if(userRoles[_address] != Payments.Role.Admin){
            delete userRoles[_address];
            emit RemoveRole(msg.sender, _address);
        }
    }
    // Query What is the role
    function queryRole(address _address) public view returns(string memory userType){
        require(hasRole(_address));
    
        if (userRoles[_address] == Payments.Role.Student) {
            return "Student";
        } else if (userRoles[_address] == Payments.Role.Admin) {
            return "Admin";
        } else if (userRoles[_address] == Payments.Role.Faculty) {
            return "Faculty";
        } else if (userRoles[_address] == Payments.Role.ShopOwner) {
            return "Shop owner";
        } else if (userRoles[_address] == Payments.Role.None) {
            return "None";
        }
    }
    // End of RBAC implementation


    // Pseudo Functions (helper functions for payments)

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
        //approve(_to, _value);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
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

    // Pseudo Functions end


    // Payment Functionalities
    
    // **Pay tuition fees require approval before hand to return true**
    function payTuitionFees(address _to, uint256 _value) public onlyAdmin returns(bool success){
       //require(userRoles[msg.sender] == Payments.Role.Student);
       emit TuitionFeesPayment( msg.sender, _to , _value);
       return transfer( _to , _value);
    }

    function payLibrary(address _address, uint256 _amount) public onlyUser returns(bool success){
        //require(hasRole(_address), "Only university members can be sent tokens.") ;
        emit PayAtLibrary(msg.sender, _address, _amount);
        return transfer(_address, _amount);
    }
    
    function payShop(address _address, uint256 _amount) public onlyUser returns(bool success){
        //require(hasRole(_address), "Only university members can be sent tokens.") ;
        emit PayAtShop(msg.sender, _address, _amount);
        return transfer(_address, _amount);
    }

    function transferToken(address _to, uint256 _amount) public onlyUser returns(bool success){
        //require(hasRole(msg.sender), "Only university members are allowed");
        return transfer(_to, _amount);
    }

    // End of Payment functionalities
}
