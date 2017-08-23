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

  it('only moderator can freeze', async function() {
    let owner = await cctoken.owner();
    let moderator = await cctoken.moderator();
    assert.isTrue(moderator !== owner);

    try {
      await cctoken.freeze(accounts[2], {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    await cctoken.freeze(accounts[2], {from: moderator});
    let isFreezed = await cctoken.isFreezed.call(accounts[2]);
    assert.isTrue(isFreezed);

  });

  it('should prevent transfer from freezed address', async function() {
    let isFreezed = await cctoken.isFreezed.call(accounts[2]);
    assert.isTrue(isFreezed);

    let acc2Balance = await cctoken.balanceOf(accounts[2]);
    assert.equal(acc2Balance, 2000);

    try {
      await cctoken.transferFrom(accounts[2], accounts[3], 100, {from: accounts[2]});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    try {
      await cctoken.transfer(accounts[1], 100, {from: accounts[2]});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
  });

  it('should prevent transfer to freezed address', async function() {
    let owner = await cctoken.owner();
    let moderator = await cctoken.moderator();
    let isFreezed = await cctoken.isFreezed.call(accounts[2]);
    assert.isTrue(isFreezed);

    let acc2Balance = await cctoken.balanceOf(accounts[2]);
    assert.equal(acc2Balance, 2000);

    try {
      await cctoken.transferFrom(accounts[0], accounts[2], 100, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    try {
      await cctoken.transfer(accounts[2], 100, {from: accounts[1]});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    try {
      await cctoken.transfer(accounts[2], 100, {from: moderator});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
  });

  it('moderator can transfer from and to freeze address', async function() {
    let moderator = await cctoken.moderator();
    let freezed = accounts[2];

    let isFreezed = await cctoken.isFreezed.call(freezed);
    assert.isTrue(isFreezed);

    let freezedBalance = await cctoken.balanceOf(freezed);
    assert.equal(freezedBalance, 2000);

    await cctoken.transferFrom(freezed, accounts[4], 150, {from: moderator});
    // check balances
    let freezedBalanceAfter = await cctoken.balanceOf(freezed);
    assert.equal(freezedBalanceAfter, 1850);
    let acc4Balance = await cctoken.balanceOf(accounts[4]);
    assert.equal(acc4Balance, 150);

    await cctoken.transferFrom(accounts[0], freezed, 40, {from: moderator});
    // check balances
    let freezedBalanceAfter2 = await cctoken.balanceOf(freezed);
    assert.equal(freezedBalanceAfter2, 1890);
  });

  it('owner can not transfer from and to freeze address', async function() {
    let owner = await cctoken.owner();
    let freezed = accounts[2];

    let isFreezed = await cctoken.isFreezed.call(freezed);
    assert.isTrue(isFreezed);

    try {
      await cctoken.transferFrom(accounts[0], freezed, 100, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    try {
      await cctoken.transferFrom(freezed, accounts[1], 100, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
  });

  it('should allow transfer for freezed address when moderator removed', async function() {
    let owner = await cctoken.owner();
    let freezed = accounts[2];

    let isFreezed = await cctoken.isFreezed.call(freezed);
    assert.isTrue(isFreezed);

    // remove moderator
    await cctoken.removeModeratorship({from: owner});
    let hasModerator = await cctoken.hasModerator.call();
    assert.isFalse(hasModerator);

    await cctoken.transfer(accounts[6], 100, {from: freezed});
    // check balances
    let freezedBalanceAfter = await cctoken.balanceOf(freezed);
    assert.equal(freezedBalanceAfter, 1790);
    let acc6Balance = await cctoken.balanceOf(accounts[6]);
    assert.equal(acc6Balance, 100);
  });

});