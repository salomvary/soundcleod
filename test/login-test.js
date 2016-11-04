'use strict'

const { Application } = require('spectron')
const assert = require('assert')
const tmp = require('tmp')

describe('Logging in', function() {
  this.timeout(15000)

  beforeEach(function() {
    // Start each test with a blank user profile
    this.userData = tmp.dirSync()
    this.app = new Application({
      args: [ 'app/main.js' ],
      env: {
        NODE_ENV: 'test',
        SOUNDCLEOD_USER_DATA_PATH: this.userData.name
      },
      path: 'node_modules/.bin/electron',
      waitTimeout: 10000
    })
    return this.app.start()
  })

  afterEach(function() {
    if (this.app && this.app.isRunning())
      return this.app.stop()
  })

  it('shows Facebook login in the main window', function() {
    return this.app.client
      .waitForVisible('#content')
      .element('#content')
      .click('button=Sign in')
      .waitForVisible('=Continue with Facebook')
      .click('=Continue with Facebook')
      .waitForVisible('span=Log into Facebook')
      .then(() => this.app.client.getUrl())
      .then(url => assertFacebookLogin(url))
      .then(() => this.app.client.getWindowCount())
      .then(windowCount => assert.equal(windowCount, 1, 'No popup is open'))
  })

  it('shows Google login in a popup', function() {
    return this.app.client
      .waitForVisible('#content')
      .element('#content')
      .click('button=Sign in')
      .waitForVisible('button=Continue with Google')
      .click('button=Continue with Google')
      .waitUntil(() => this.app.client.getWindowCount().then(count => count > 1))
      .then(() => this.app.client.getWindowCount())
      .then(windowCount => assert.equal(windowCount, 2, 'Opened a popup'))
  })

  function assertFacebookLogin(url) {
    assert.ok(url.includes('www.facebook.com/login'), `'${url}' looks like a Facebook url`)
  }
})
