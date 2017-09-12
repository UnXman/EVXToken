'use strict';
const assertJump = require('./helpers/assertJump');

var evxOwnable = artifacts.require('../contracts/ownership/evxOwnable.sol');

contract('evxOwnable', function(accounts) {
  let ownable;

  beforeEach(async function() {
    ownable = await evxOwnable.new();
  });

  it('should have an owner', async function() {
    let owner = await ownable.owner();
    assert.isTrue(owner !== 0);
  });

  it('changes owner after transfer', async function() {
    let initial = accounts[0];
    let other = accounts[1];

    // transfer ownership
    await ownable.transferOwnership(other);
    let newOwner = await ownable.newOwner();
    let owner = await ownable.owner();
    assert.isTrue(newOwner === other);
    assert.isTrue(owner === initial);

    // approve ownership
    await ownable.approveOwnership({from: other});
    let owner = await ownable.owner();
    assert.isTrue(owner === other);
  });

  it('should prevent non-owners from transfering', async function() {
    const other = accounts[2];
    const owner = await ownable.owner.call();
    assert.isTrue(owner !== other);
    try {
      await ownable.transferOwnership(other, {from: other});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
  });

  it('should guard ownership against stuck state', async function() {
    let originalOwner = await ownable.owner();
    try {
      await ownable.transferOwnership(null, {from: originalOwner});
      assert.fail();
    } catch(error) {
      assertJump(error);
    }
  });

});