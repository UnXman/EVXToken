pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  address public newOwner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to an otherOwner.
   * @param otherOwner The address to transfer ownership to.
   */
  function transferOwnership(address otherOwner) onlyOwner {
    require(otherOwner != address(0));      
    newOwner = otherOwner;
  }

  /**
   * @dev Complete ownership transfer.
   */
  function approveOwnership() {
    require(msg.sender == newOwner);
    owner = newOwner;
  }
}

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {

  function Destructible() payable { } 

  /**
   * @dev Transfers the current balance to the owner and terminates the contract. 
   */
  function destroy() onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner {
    selfdestruct(_recipient);
  }
}

/**
 * @title Moderated
 * @dev Moderator can make transfers from and to any account (including frozen).
 */
contract Moderated is Ownable {

  address public moderator;
  address public newModerator;

  /**
   * @dev Throws if called by any account other than the moderator.
   */
  modifier onlyModerator() {
    require(msg.sender == moderator);
    _;
  }

  /**
   * @dev Throws if called by any account other than the owner or moderator.
   */
  modifier onlyOwnerOrModerator() {
    require((msg.sender == moderator) || (msg.sender == owner));
    _;
  }

  /**
   * @dev Moderator same as owner
   */
  function Moderated(){
    moderator = msg.sender;
  }

  /**
   * @dev Allows the current moderator to transfer control of the contract to an otherModerator.
   * @param otherModerator The address to transfer moderatorship to.
   */
  function transferModeratorship(address otherModerator) onlyModerator {
    newModerator = otherModerator;
  }

  /**
   * @dev Complete moderatorship transfer.
   */
  function approveModeratorship() {
    require(msg.sender == newModerator);
    moderator = newModerator;
  }

  /**
   * @dev Removes moderator from the contract.
   * After this point, moderator role will be eliminated completly.
   */
  function removeModeratorship() onlyOwner {
      moderator = address(0);
  }

  function hasModerator() returns(bool) {
      return (moderator == address(0));
  }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable, Moderated {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwnerOrModerator whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwnerOrModerator whenPaused {
    paused = false;
    Unpause();
  }
}

/**
 * @title ERC20Basic
 * @dev ERC20 interface
 */
contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is ERC20 {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
}

/**
 * EVX token
 **/
contract EVXToken is StandardToken, Pausable, Destructible {

  mapping(address => bool) freezed;

  function isFreezed(address _addr) returns (bool){
      return freezed[_addr] && !hasModerator();
  }

  function freeze(address _addr) onlyModerator {
      freezed[_addr] = true;
  }

  function unfreeze(address _addr) onlyModerator {
      freezed[_addr] = false;
  }

  function transfer(address _to, uint256 _value) whenNotPaused returns (bool) {
    require(!isFreezed(msg.sender));
    require(!isFreezed(_to));
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) onlyModerator whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}
