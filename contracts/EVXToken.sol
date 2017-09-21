pragma solidity ^0.4.13;

import './token/evxModeratedToken.sol';

/**
 * EVXToken
 **/
contract EVXToken is evxModeratedToken {
  string public constant name = "Everex";
  string public constant symbol = "EVX";
  uint256 public constant decimals = 4;
  uint256 initialSupply = 250000000000;

  /**
   * @dev Contructor that gives msg.sender all of existing tokens. 
   */
  function EVXToken(uint256 _initialSupply) {   
    if(_initialSupply > 0){
        initialSupply = _initialSupply;
    }
    totalSupply = initialSupply;
    balances[msg.sender] = initialSupply;
    // Contract initializes in paused state
    // paused = true;
  }
}

