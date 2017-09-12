pragma solidity ^0.4.11;

import '../../contracts/token/evxModeratedToken.sol';

// mock class using PausableToken
contract evxModeratedTokenMock is evxModeratedToken {

  function evxModeratedTokenMock(address initialAccount, uint initialBalance) {
    balances[initialAccount] = initialBalance;
  }

}
