pragma solidity ^0.4.11;

import "../../OpenZeppelin/contracts/token/StandardToken.sol";

import './StandardToken.sol';
import '../lifecycle/evxPausable.sol';

/**
 * Pausable token
 *
 * Simple ERC20 Token example, with pausable token creation
 **/

contract evxPausableToken is StandardToken, evxPausable {

  mapping(address => bool) freezed;

  function isFreezed(address _addr) returns (bool){
      return freezed[_addr] && hasModerator();
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

  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused returns (bool) {
    require(!isFreezed(msg.sender));
    require(!isFreezed(_from));
    require(!isFreezed(_to));
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Transfer tokens from one address to another
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
