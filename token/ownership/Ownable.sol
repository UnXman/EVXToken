pragma solidity ^0.4.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  address public newOwner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

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
    owner = newOwner;
  }
}
