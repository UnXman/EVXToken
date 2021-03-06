'use strict';
const assertJump = require('../OpenZeppelin/test/helpers/assertJump');
var evxModerated = artifacts.require('../contracts/ownership/evxModerated.sol');

contract('evxModerated', function(accounts) {
  let moderated;

  before(async function() {
    moderated = await evxModerated.new();
  });

  it('should moderator == owner after creation', async function() {
    let moderator = await moderated.moderator();
    let owner = await moderated.owner();
    assert.isTrue(moderator == owner);
  });

  it('should change moderator', async function() {
    let other = accounts[1];
    let owner = await moderated.owner();
    let moderator = await moderated.moderator();

    assert.isTrue(moderator === owner);

    // change moderator
    await moderated.transferModeratorship(other, {from: moderator});
    let newModerator = await moderated.newModerator();
    assert.isTrue(newModerator === other);

    // approve moderator
    await moderated.approveModeratorship({from: other});
    let approvedModerator = await moderated.moderator();
    assert.isTrue(approvedModerator === other);
  });

  it('should prevent non-moderator from changing moderator', async function() {
    let owner = await moderated.owner();
    let moderator = await moderated.moderator();

    assert.isTrue(moderator != owner);
    try {
      await moderated.transferModeratorship(owner, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
  });

  it('only owner can remove moderator', async function() {
    let owner = await moderated.owner();
    let moderator = await moderated.moderator();
    assert.isTrue(moderator != owner);

    try {
      await moderated.removeModeratorship({from: moderator});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    await moderated.removeModeratorship({from: owner});
    let hasModerator = await moderated.hasModerator.call();
    assert.isFalse(hasModerator);

    let newModerator = await moderated.newModerator();
    assert.isTrue(newModerator == 0);
  });

});