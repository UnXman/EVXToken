'use strict';
const assertJump = require('./helpers/assertJump');

var CCToken = artifacts.require('../contracts/CCToken.sol');

contract('CCToken', function(accounts) {
  let cctoken;

  before(async function() {
    cctoken = await CCToken.new(25000000);
  });

  it('should change moderator', async function() {
    let other = accounts[1];
    let owner = await cctoken.owner();
    let moderator = await cctoken.moderator();

    assert.isTrue(moderator === owner);

    // change moderator
    await cctoken.transferModeratorship(other, {from: moderator});
    let newModerator = await cctoken.newModerator();
    assert.isTrue(newModerator === other);

    // approve moderator
    await cctoken.approveModeratorship({from: other});
    let approvedModerator = await cctoken.moderator();
    assert.isTrue(approvedModerator === other);
  });

  it('only moderator can do transfer from', async function() {
    let owner = await cctoken.owner();
    let moderator = await cctoken.moderator();
    assert.isTrue(moderator !== owner);

    try {
      await cctoken.transferFrom(accounts[1], accounts[2], 2000, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    let ownerBalance = await cctoken.balanceOf(owner);
    assert.equal(ownerBalance, 25000000);

    // transfer 2000 to accounts[2]
    await cctoken.transferFrom(accounts[0], accounts[2], 2000, {from: moderator});

    // check balances
    let ownerBalanceAfter = await cctoken.balanceOf(owner);
    assert.equal(ownerBalanceAfter, 24998000);

    let acc2Balance = await cctoken.balanceOf(accounts[2]);
    assert.equal(acc2Balance, 2000);
  });

  it('only moderator or owner can pause', async function() {
    let owner = await cctoken.owner();
    let moderator = await cctoken.moderator();
    assert.isTrue(moderator !== owner);

    try {
      await cctoken.pause({from: accounts[2]});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    await cctoken.pause({from: owner});
    let paused1 = await cctoken.paused();
    assert.equal(paused1, true);
    await cctoken.unpause({from: owner});
    let paused2 = await cctoken.paused();
    assert.equal(paused2, false);

    await cctoken.pause({from: moderator});
    let paused3 = await cctoken.paused();
    assert.equal(paused3, true);
    await cctoken.unpause({from: moderator});
    let paused4 = await cctoken.paused();
    assert.equal(paused4, false);
  });

});