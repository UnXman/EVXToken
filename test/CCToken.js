'use strict';
const assertJump = require('./helpers/assertJump');

var CCToken = artifacts.require('../contracts/CCToken.sol');

contract('CCToken', function(accounts) {
  let cctoken;

  before(async function() {
    cctoken = await CCToken.new();
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

  it('only moderator can do transfer', async function() {
    let owner = await cctoken.owner();
    let moderator = await cctoken.moderator();
    assert.isTrue(moderator !== owner);

    try {
      await cctoken.transferFrom(accounts[1], accounts[2], 200000, {from: owner});
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    /*console.log(accounts[1]);
    let bal1 = web3.eth.getBalance(accounts[1]);//await cctoken.balanceOf(accounts[1]);
    console.log(bal1.toString(10));*/

    //await cctoken.transferFrom(accounts[1], accounts[2], 200000, {from: moderator});
  });

});