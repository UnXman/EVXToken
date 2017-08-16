pragma solidity ^0.4.11;

import './token/PausableToken.sol';
import './lifecycle/Destructible.sol';

/**
 * CCToken
 **/
contract CCToken is PausableToken, Destructible {
}

