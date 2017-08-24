pragma solidity ^0.4.11;

import './token/PausableToken.sol';
import './lifecycle/Destructible.sol';

/**
 * EVXToken
 **/
contract EVXToken is PausableToken, Destructible {
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

