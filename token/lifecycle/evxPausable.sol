pragma solidity ^0.4.11;

import "../../OpenZeppelin/contracts/lifecycle/Pausable.sol";
import "../ownership/Moderated.sol";


/**
 * @title evxPausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract evxPausable is Pausable, Moderated {
  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwnerOrModerator whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwnerOrModerator whenPaused {
    paused = false;
    Unpause();
  }
}
