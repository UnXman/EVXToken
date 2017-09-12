pragma solidity ^0.4.11;

import "../../OpenZeppelin/contracts/lifecycle/Pausable.sol";
import "../ownership/evxModerated.sol";


/**
 * @title evxPausable
 * @dev Slightly modified implementation of an emergency stop mechanism.
 */
contract evxPausable is Pausable, evxModerated {
  /**
   * @dev called by the owner or moderator to pause, triggers stopped state
   */
  function pause() onlyOwnerOrModerator whenNotPaused {
    super.pause();
  }

  /**
   * @dev called by the owner or moderator to unpause, returns to normal state
   */
  function unpause() onlyOwnerOrModerator whenPaused {
    super.unpause();
  }
}
