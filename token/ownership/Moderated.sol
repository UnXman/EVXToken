pragma solidity ^0.4.11;

import "./Ownable.sol";

/**
 * @title Moderated
 * @dev Moderator can make transfers from and to any account (including frozen).
 */
contract Moderated is Ownable {

  address public moderator;
  address public newModerator;

  /**
   * @dev Throws if called by any account other than the moderator.
   */
  modifier onlyModerator() {
    require(msg.sender == moderator);
    _;
  }

  /**
   * @dev Throws if called by any account other than the owner or moderator.
   */
  modifier onlyOwnerOrModerator() {
    require((msg.sender == moderator) || (msg.sender == owner));
    _;
  }

  /**
   * @dev Moderator same as owner
   */
  function Moderated(){
    moderator = msg.sender;
  }

  /**
   * @dev Allows the current moderator to transfer control of the contract to an otherModerator.
   * @param otherModerator The address to transfer moderatorship to.
   */
  function transferModeratorship(address otherModerator) onlyModerator {
    newModerator = otherModerator;
  }

  /**
   * @dev Complete moderatorship transfer.
   */
  function approveModeratorship() {
    require(msg.sender == newModerator);
    moderator = newModerator;
  }

  /**
   * @dev Removes moderator from the contract.
   * After this point, moderator role will be eliminated completly.
   */
  function removeModeratorship() onlyOwner {
      moderator = address(0);
  }

  function hasModerator() returns(bool) {
      return (moderator != address(0));
  }
}
