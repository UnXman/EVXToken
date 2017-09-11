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

  function transferFrom(address _from, address _to, uint256 _value) onlyModerator returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}
