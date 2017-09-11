pragma solidity ^0.4.12;

import './token/evxPausableToken.sol';
import '../OpenZeppelin/contracts/lifecycle/Destructible.sol';

/**
 * EVXToken
 **/
contract EVXToken is evxPausableToken, Destructible {
  string public constant name = "Everex";
  string public constant symbol = "EVX";
  uint256 public constant decimals = 4;

  /**
   * @dev Contructor that gives msg.sender all of existing tokens. 
   */
  function EVXToken(uint256 _initialSupply) {
    totalSupply = _initialSupply;
    balances[msg.sender] = _initialSupply;
  }
}

