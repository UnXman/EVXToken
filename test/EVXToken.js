'use strict';
const assertJump = require('../OpenZeppelin/test/helpers/assertJump');
var EVXToken = artifacts.require('../contracts/EVXToken.bundle.sol');

contract('EVXToken', function(accounts) {
  let evxtoken;

  before(async function() {
    evxtoken = await EVXToken.new(25000000);
  });

  it('should change moderator', async function() {
    let other = accounts[1];
    let owner = await evxtoken.owner();
    let moderator = await evxtoken.moderator();

    assert.isTrue(moderator === owner);

    // change moderator
    await evxtoken.transferModeratorship(other, {from: moderator});
    let newModerator = await evxtoken.newModerator();
    assert.isTrue(newModerator === other);

    // approve moderator
    await evxtoken.approveModeratorship({from: other});
    let approvedModerator = await evxtoken.moderator();
    assert.isTrue(approvedModerator === other);
  });

  it('only moderator can do moderatorTransferFrom', async function() {
    let owner = await evxtoken.owner();
    let moderator = await evxtoken.moderator();
    assert.isTrue(moderator !== owner);

    try {
      await evxtoken.moderatorTransferFrom(accounts[1], accounts[2], 2000, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    let ownerBalance = await evxtoken.balanceOf(owner);
    assert.equal(ownerBalance, 25000000);

    // transfer 2000 to accounts[2]
    await evxtoken.moderatorTransferFrom(accounts[0], accounts[2], 2000, {from: moderator});

    // check balances
    let ownerBalanceAfter = await evxtoken.balanceOf(owner);
    assert.equal(ownerBalanceAfter, 24998000);

    let acc2Balance = await evxtoken.balanceOf(accounts[2]);
    assert.equal(acc2Balance, 2000);
  });

  it('only moderator or owner can pause', async function() {
    let owner = await evxtoken.owner();
    let moderator = await evxtoken.moderator();
    assert.isTrue(moderator !== owner);

    try {
      await evxtoken.pause({from: accounts[2]});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    await evxtoken.pause({from: owner});
    let paused1 = await evxtoken.paused();
    assert.equal(paused1, true);
    await evxtoken.unpause({from: owner});
    let paused2 = await evxtoken.paused();
    assert.equal(paused2, false);

    await evxtoken.pause({from: moderator});
    let paused3 = await evxtoken.paused();
    assert.equal(paused3, true);
    await evxtoken.unpause({from: moderator});
    let paused4 = await evxtoken.paused();
    assert.equal(paused4, false);
  });

  it('only moderator can freeze', async function() {
    let owner = await evxtoken.owner();
    let moderator = await evxtoken.moderator();
    assert.isTrue(moderator !== owner);

    try {
      await evxtoken.freeze(accounts[2], {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    await evxtoken.freeze(accounts[2], {from: moderator});
    let isFrozen = await evxtoken.isFrozen.call(accounts[2]);
    assert.isTrue(isFrozen);

  });

  it('should prevent transfer from frozen address', async function() {
    let isFrozen = await evxtoken.isFrozen.call(accounts[2]);
    assert.isTrue(isFrozen);

    let acc2Balance = await evxtoken.balanceOf(accounts[2]);
    assert.equal(acc2Balance, 2000);

    try {
      await evxtoken.transfer(accounts[3], 100, {from: accounts[2]});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    try {
      await evxtoken.transfer(accounts[1], 100, {from: accounts[2]});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
  });

  it('should prevent transfer to frozen address', async function() {
    let owner = await evxtoken.owner();
    let moderator = await evxtoken.moderator();
    let isFrozen = await evxtoken.isFrozen.call(accounts[2]);
    assert.isTrue(isFrozen);

    let acc2Balance = await evxtoken.balanceOf(accounts[2]);
    assert.equal(acc2Balance, 2000);

    try {
      await evxtoken.transfer(accounts[2], 100, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    try {
      await evxtoken.transfer(accounts[2], 100, {from: accounts[1]});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    try {
      await evxtoken.transfer(accounts[2], 100, {from: moderator});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
  });

  it('moderator can transfer from and to freeze address', async function() {
    let moderator = await evxtoken.moderator();
    let frozen = accounts[2];

    let isFrozen = await evxtoken.isFrozen.call(frozen);
    assert.isTrue(isFrozen);

    let frozenBalance = await evxtoken.balanceOf(frozen);
    assert.equal(frozenBalance, 2000);

    await evxtoken.moderatorTransferFrom(frozen, accounts[4], 150, {from: moderator});
    // check balances
    let frozenBalanceAfter = await evxtoken.balanceOf(frozen);
    assert.equal(frozenBalanceAfter, 1850);
    let acc4Balance = await evxtoken.balanceOf(accounts[4]);
    assert.equal(acc4Balance, 150);

    await evxtoken.moderatorTransferFrom(accounts[0], frozen, 40, {from: moderator});
    // check balances
    let frozenBalanceAfter2 = await evxtoken.balanceOf(frozen);
    assert.equal(frozenBalanceAfter2, 1890);
  });

  it('owner can not transfer from and to freeze address', async function() {
    let owner = await evxtoken.owner();
    let frozen = accounts[2];

    let isFrozen = await evxtoken.isFrozen.call(frozen);
    assert.isTrue(isFrozen);

    try {
      await evxtoken.transfer(frozen, 100, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    try {
      await evxtoken.moderatorTransferFrom(frozen, accounts[1], 100, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
  });

  it('Only moderator can unfreeze address', async function() {
    let owner = await evxtoken.owner();
    let moderator = await evxtoken.moderator();
    let frozen = accounts[2];

    let isFrozen = await evxtoken.isFrozen.call(frozen);
    assert.isTrue(isFrozen);

    try {
      await evxtoken.unfreeze(frozen, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    await evxtoken.unfreeze(frozen, {from: moderator});
    isFrozen = await evxtoken.isFrozen.call(frozen);
    assert.isTrue(!isFrozen);

    await evxtoken.freeze(frozen, {from: moderator});
    isFrozen = await evxtoken.isFrozen.call(frozen);
    assert.isTrue(isFrozen);
  });

  it('should allow transfer for frozen address when moderator removed', async function() {
    let owner = await evxtoken.owner();
    let frozen = accounts[2];

    let isFrozen = await evxtoken.isFrozen.call(frozen);
    assert.isTrue(isFrozen);

    // remove moderator
    await evxtoken.removeModeratorship({from: owner});
    let hasModerator = await evxtoken.hasModerator.call();
    assert.isFalse(hasModerator);

    await evxtoken.transfer(accounts[6], 100, {from: frozen});
    // check balances
    let frozenBalanceAfter = await evxtoken.balanceOf(frozen);
    assert.equal(frozenBalanceAfter, 1790);
    let acc6Balance = await evxtoken.balanceOf(accounts[6]);
    assert.equal(acc6Balance, 100);
  });

});