// Ownership
contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

// Mortality (temporary)
contract mortal is owned {
    function kill() onlyOwner {
        if(this.balance > 0){
            if (!msg.sender.send(this.balance)) throw;
        }
        suicide(msg.sender);
    }
}

// Token Controller
contract  EverTokenController is owned, mortal
{
    /* Configuration */
    mapping(string => uint256) private tokenConfig;

    /* Main token */
    address private tokenAddress;

    /* Frozen accounts */
    mapping (address => bool) private frozenAccount;

    /* Daily limits */
    mapping (address => uint256[2]) private dailyLimits;

    /* This operation can be done by master token only */
    modifier masterToken {
        if (msg.sender != tokenAddress) throw;
        if(getConfig('contract.isActive') == 0) throw;
        _
    }

    /* Constructor */
    function EverTokenController(){
        setConfig('contract.isActive', 1);
        setConfig('transfer.limit.isActive', 0);
        setConfig('transfer.limit.daily', 100000);
        setConfig('refill.refillTo', 5 finney);
        setConfig('refill.minBalance', 3 finney);
        setConfig('freeze.ownerCanSend', 1);
    }

    /* Sets configuration option */
    function setConfig(string _key, uint256 _value) onlyOwner {
        tokenConfig[_key] = _value;
    }

    /* Returns configuration option */
    function getConfig(string _key) constant returns (uint256 _value){
        return tokenConfig[_key];
    }

    /* Checks daily limits */
    function checkDailyLimits(address _address, uint256 _value) returns (bool result){
        var lastDay = dailyLimits[_address][0];
        var totalSent = dailyLimits[_address][1];
        var today = now / 1 days;

        if (today > lastDay) {
            dailyLimits[_address][1] = 0;
            dailyLimits[_address][0] = today;
        }

        result = ((totalSent + _value) <= getConfig('transfer.limit.daily'));

        if(result){
            dailyLimits[_address][1] = totalSent + _value;
        }

        return result;
    }

    /* Refill address ether */
    function refill(address _address) masterToken {
        var minBalance = getConfig('refill.minBalance');
        var refillTo = getConfig('refill.refillTo');
        if(_address.balance < minBalance){
            if (!_address.send(refillTo - _address.balance)) throw;
        }
    }

    /* A contract attempts to get the coins */
    function send(address _from, address _to, uint256 _value) masterToken returns (bool) {
        if(_value == 0){
            return _err('zero_amount');
        }

        // Cannot send from and to frozen account (but the owner can send anywhere)
        if((tx.origin != owner) || (getConfig('freeze.ownerCanSend') == 0)){
            if(frozenAccount[_from]){
                return _err('frozen_account_source');
            }
            if(frozenAccount[_to]){
                return _err('frozen_account_destination');
            }
        }

        var token = EverToken(tokenAddress);
        var (balanceFrom, balanceTo) = token.getBalances(_from, _to);

        // Check if the sender has enough
        if (balanceFrom < _value){
            return _err('insufficient_funds');
        }

        // Check for overflows
        if (balanceTo + _value < 0){
            return _err('possible_overflow');
        }

        // Checks limits
        if(getConfig('transfer.limit.isActive') != 0){
            if(!checkDailyLimits(_from, _value)){
                return _err('daily_limit_exceeded');
            }
        }

        token.setAddressBalance(_from, balanceFrom - _value); // Subtract from the sender
        token.setAddressBalance(_to, balanceTo + _value); // Add the same to the recipient

        // Autorefill ether
        if(balanceFrom != _value){
            // Autorefill sender only if sender balance is positive
            refill(_from);
        }
        refill(_to);

        return true;
    }

    /* Freezes account */
    function freeze(address _address, bool _value) masterToken returns (bool) {
        frozenAccount[_address] = _value;
        return true;
    }

    /* Issue specific amount of coins */
    function issue(address _address, uint256 _value) masterToken returns (bool) {
        if(_value == 0){
            return _err('zero_amount');
        }

        var token = EverToken(tokenAddress);
        var balance = token.getBalanceOf(_address);

        // Check for overflows
        if(balance + _value < 0){
            return _err('possible_overflow');
        }

        balance += _value;
        token.setAddressBalance(_address, balance);
        token.updateTotalSupply(_value);

        return true;
    }

    /* Burn specific amount of coins */
    function burn(address _address, uint256 _value) masterToken returns (bool) {
        if(_value == 0){
            return _err('zero_amount');
        }

        var token = EverToken(tokenAddress);
        var balance = token.getBalanceOf(_address);

        if (balance - _value < 0){
            _value = balance;
        }

        balance -= _value;

        token.setAddressBalance(_address, balance);
        token.updateTotalSupply(-_value);

        return true;
    }

    /* Generates error event */
    function _err(string reason) returns (bool) {
        var token = EverToken(tokenAddress);
        token.invalidOp(reason);
        return false;
    }

    /* Sets master token contract address */
    function setToken(address _tokenAddress) onlyOwner {
        tokenAddress = _tokenAddress;
    }
}

// Master Token contract
contract  EverToken is owned, mortal
{
    /* Public variables of the token */
    string public name;
    string public symbol;
    string public version;
    uint8 public decimals;

    uint256 public totalSupply;

    struct balanceChanges {address addr; uint256 val;}

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* Frozen accounts */
    mapping (address => bool) public frozenAccount;

    /* Token Controller */
    address public tokenControllerAddress;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    event evtTransfer(address indexed from, address indexed to, uint256 value, uint ts);
    event evtIssuance(address indexed issuer, uint256 value, uint ts);
    event evtBurn(address indexed issuer, uint256 value, uint ts);
    event evtFreeze(address indexed target, bool frozen, uint ts);
    event evtError(string reason, uint ts);
    event evtControllerChanged(uint ts);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function  EverToken(
        uint256 initialSupply,
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        string description
    ) {
        owner = msg.sender;                                 // Sets the owner
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        decimals = decimalUnits;                            // Amount of decimals for display purposes
        totalSupply = initialSupply;
        evtIssuance(msg.sender, initialSupply, block.timestamp);
    }

    /* Method can be called by controller contract only */
    modifier onlyController {
        if (msg.sender != tokenControllerAddress) throw;
        _
    }

    /* Method can be called by owner and controller contract only */
    modifier onlyOwnerAndController {
        if ((msg.sender != tokenControllerAddress) && (msg.sender != owner)) throw;
        _
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) returns (bool success) {
        return transferFrom(msg.sender, _to, _value);
    }

    /* Broadcast message */
    function broadcast(string _message) onlyOwner {}

    /* Set token controller address */
    function setController(address _addr) onlyOwner {
        tokenControllerAddress = _addr;
        evtControllerChanged(block.timestamp);
    }

    /* Getter */
    function getBalanceOf(address _address) constant returns (uint256 balance){
        return balanceOf[_address];
    }

    /* Getter (for the fuel economy) */
    function getBalances(address _address1, address _address2) constant returns (uint256 balance1, uint256 balance2){
        return (balanceOf[_address1], balanceOf[_address2]);
    }

    /* Setter */
    function setAddressBalance(address _address, uint256 _value) onlyController {
        balanceOf[_address] = _value;
    }

    /* Change totalSupply (burn and issue) */
    function updateTotalSupply(uint256 _value) onlyController {
        totalSupply += _value;
    }

    /* To use from controller */
    function setAddressFrozen(address _address, bool _value) onlyController {
        frozenAccount[_address] = _value;
    }

    /* Freeze Account */
    function freezeAccount(address _address, bool _value) onlyOwner {
        EverTokenController(tokenControllerAddress).freeze(_address, _value);
        evtFreeze(_address, _value, block.timestamp);
    }

    /* Issue new coins */
    function issue(uint256 _value, string _description) onlyOwner returns (bool result) {
        result = EverTokenController(tokenControllerAddress).issue(msg.sender, _value);
        if(result){
            evtIssuance(msg.sender, _value, block.timestamp);
        }
        return result;
    }

    /*Burn coins */
    function burn(uint256 _value, string _description) onlyOwner returns (bool result) {
        result = EverTokenController(tokenControllerAddress).burn(msg.sender, _value);
        if(result){
            evtBurn(msg.sender, _value, block.timestamp);
        }
        return result;
    }

    /* Generates error event */
    function invalidOp(string reason){
        evtError(reason, block.timestamp);
    }

    /* Actual send code */
    function transferFrom( address _from, address _to, uint256 _value) returns (bool result){
        // Only owner can perform free sends
        if((_from != msg.sender) && (msg.sender != owner)) throw;
        // Cannot send to the same account
        if((_from == _to)) throw;
        // Send
        result = EverTokenController(tokenControllerAddress).send(_from, _to, _value);
        if(result){
            Transfer(_from, _to, _value);
            evtTransfer(_from, _to, _value, block.timestamp);
        }
        return result;
    }
}
