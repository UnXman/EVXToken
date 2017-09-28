pragma solidity ^0.4.13;

import './token/header.sol';
import './token/evxModeratedToken.sol';

/**
 * EVXToken
 **/
contract EVXToken is evxModeratedToken {
  string public constant name = "Everex";
  string public constant symbol = "EVX";
  uint256 public constant decimals = 4;

  /**
   * @dev Constructor that gives msg.sender all of existing tokens.
   */
  function EVXToken(uint256 _initialSupply) {
    totalSupply = _initialSupply;
    balances[msg.sender] = _initialSupply;
  }
}

