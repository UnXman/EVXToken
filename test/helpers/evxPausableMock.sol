pragma solidity ^0.4.11;


import '../../contracts/lifecycle/evxPausable.sol';


// mock class using Pausable
contract evxPausableMock is evxPausable {
  bool public drasticMeasureTaken;
  uint256 public count;

  function evxPausableMock() {
    drasticMeasureTaken = false;
    count = 0;
  }

  function normalProcess() external whenNotPaused {
    count++;
  }

  function drasticMeasure() external whenPaused {
    drasticMeasureTaken = true;
  }

}
