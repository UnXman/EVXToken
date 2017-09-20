pragma solidity ^0.4.11;

import "../../OpenZeppelin/contracts/token/StandardToken.sol";
import '../lifecycle/evxPausable.sol';

/**
 * Pausable token with moderator role and freeze address implementation
 *
 **/
contract evxModeratedToken is StandardToken, evxPausable {

  mapping(address => bool) freezed;

  /**
   * @dev Check if given address is freezed. Freeze works only if moderator role is active
   * @param _addr address Address to check
   */
  function isFreezed(address _addr) constant returns (bool){
      return freezed[_addr] && hasModerator();
  }

  /**
   * @dev Freezes address (no transfer can be made from or to this address).
   * @param _addr address Address to be freezed
   */
  function freeze(address _addr) onlyModerator {
      freezed[_addr] = true;
  }

  /**
   * @dev Unfreezes freezed address.
   * @param _addr address Address to be unfreezed
   */
  function unfreeze(address _addr) onlyModerator {
      freezed[_addr] = false;
  }

  /**
   * @dev Declines transfers from/to freezed addresses.
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transfer(address _to, uint256 _value) whenNotPaused returns (bool) {
    require(!isFreezed(msg.sender));
    require(!isFreezed(_to));
    return super.transfer(_to, _value);
  }

  /**
   * @dev Declines transfers from/to/by freezed addresses.
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused returns (bool) {
    require(!isFreezed(msg.sender));
    require(!isFreezed(_from));
    require(!isFreezed(_to));
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