pragma solidity ^0.4.11;

import '../../contracts/token/evxModeratedToken.sol';

// mock class using PausableToken
contract PausableTokenMock is evxModeratedToken{

  function PausableTokenMock(address initialAccount, uint initialBalance) {
    balances[initialAccount] = initialBalance;
  }

}
