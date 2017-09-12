'use strict';

const assertJump = require('./helpers/assertJump');
const evxPausableMock = artifacts.require('helpers/evxPausableMock.sol');

var evxPausable = artifacts.require('../contracts/lifecycle/evxPausable.sol');

contract('evxPausable', function(accounts) {

  it('can perform normal process in non-pause', async function() {
    let evxPausable = await evxPausableMock.new();
    let count0 = await evxPausable.count();
    assert.equal(count0, 0);

    await evxPausable.normalProcess();
    let count1 = await evxPausable.count();
    assert.equal(count1, 1);
  });

  it('can not perform normal process in pause', async function() {
    let evxPausable = await evxPausableMock.new();
    await evxPausable.pause();
    let count0 = await evxPausable.count();
    assert.equal(count0, 0);

    try {
      await Pausable.normalProcess();
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
    let count1 = await Pausable.count();
    assert.equal(count1, 0);
  });


  it('can not take drastic measure in non-pause', async function() {
    let evxPausable = await evxPausableMock.new();
    try {
      await evxPausable.drasticMeasure();
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }
    const drasticMeasureTaken = await evxPausable.drasticMeasureTaken();
    assert.isFalse(drasticMeasureTaken);
  });

  it('can take a drastic measure in a pause', async function() {
    let evxPausable = await evxPausableMock.new();
    await evxPausable.pause();
    await evxPausable.drasticMeasure();
    let drasticMeasureTaken = await evxPausable.drasticMeasureTaken();

    assert.isTrue(drasticMeasureTaken);
  });

  it('should resume allowing normal process after pause is over', async function() {
    let evxPausable = await evxPausableMock.new();
    await evxPausable.pause();
    await evxPausable.unpause();
    await evxPausable.normalProcess();
    let count0 = await evxPausable.count();

    assert.equal(count0, 1);
  });

  it('should prevent drastic measure after pause is over', async function() {
    let evxPausable = await evxPausableMock.new();
    await evxPausable.pause();
    await evxPausable.unpause();
    try {
      await evxPausable.drasticMeasure();
      assert.fail('should have thrown before');
    } catch(error) {
      assertJump(error);
    }

    const drasticMeasureTaken = await evxPausable.drasticMeasureTaken();
    assert.isFalse(drasticMeasureTaken);
  });

});
