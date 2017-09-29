pragma solidity ^0.4.13;

import './token/evxModeratedToken.sol';

/**
 * EVXToken
 **/
contract EVXToken is evxModeratedToken {
  string public constant version = "1.0";
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

