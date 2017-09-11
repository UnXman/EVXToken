pragma solidity ^0.4.11;

import '../../contracts/token/evxPausableToken.sol';

// mock class using PausableToken
contract PausableTokenMock is evxPausableToken {

  function PausableTokenMock(address initialAccount, uint initialBalance) {
    balances[initialAccount] = initialBalance;
  }

}
