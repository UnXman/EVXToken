pragma solidity ^0.4.11;

import "../../OpenZeppelin/contracts/ownership/Ownable.sol";

/**
 * @title evxOwnable
 * @dev The evxOwnable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract evxOwnable is Ownable {

  address public newOwner;

  /**
   * @dev Allows the current owner to transfer control of the contract to an otherOwner.
   * @param otherOwner The address to transfer ownership to.
   */
  function transferOwnership(address otherOwner) onlyOwner {
    require(otherOwner != address(0));      
    newOwner = otherOwner;
  }

  /**
   * @dev Finish ownership transfer.
   */
  function approveOwnership() {
    require(msg.sender == newOwner);
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}
