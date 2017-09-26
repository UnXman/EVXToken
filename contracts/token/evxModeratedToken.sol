pragma solidity ^0.4.11;

import "../../OpenZeppelin/contracts/token/StandardToken.sol";
import '../lifecycle/evxPausable.sol';

/**
 * Pausable token with moderator role and freeze address implementation
 *
 **/
contract evxModeratedToken is StandardToken, evxPausable {

  mapping(address => bool) frozen;

  /**
   * @dev Check if given address is frozen. Freeze works only if moderator role is active
   * @param _addr address Address to check
   */
  function isFrozen(address _addr) constant returns (bool){
      return frozen[_addr] && hasModerator();
  }

  /**
   * @dev Freezes address (no transfer can be made from or to this address).
   * @param _addr address Address to be frozen
   */
  function freeze(address _addr) onlyModerator {
      frozen[_addr] = true;
  }

  /**
   * @dev Unfreezes frozen address.
   * @param _addr address Address to be unfrozen
   */
  function unfreeze(address _addr) onlyModerator {
      frozen[_addr] = false;
  }

  /**
   * @dev Declines transfers from/to frozen addresses.
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transfer(address _to, uint256 _value) whenNotPaused returns (bool) {
    require(!isFrozen(msg.sender));
    require(!isFrozen(_to));
    return super.transfer(_to, _value);
  }

  /**
   * @dev Declines transfers from/to/by frozen addresses.
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused returns (bool) {
    require(!isFrozen(msg.sender));
    require(!isFrozen(_from));
    require(!isFrozen(_to));
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Allows moderator to transfer tokens from one address to another.
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function moderatorTransferFrom(address _from, address _to, uint256 _value) onlyModerator returns (bool) {
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
}