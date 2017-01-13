'use strict'

const applicationHelper = require('./application-helper')
const assert = require('assert')

describe('Logging in', function() {

  applicationHelper()

  it('shows Facebook login in the main window', function() {
    return this.app.client
      .waitForVisible('button=Sign in')
      .element('#content')
      .click('button=Sign in')
      .waitForVisible('=Continue with Facebook')
      .click('=Continue with Facebook')
      .waitForVisible('span=Log in to Facebook')
      .then(() => this.app.client.getUrl())
      .then(url => assertFacebookLogin(url))
      .then(() => this.app.client.getWindowCount())
      .then(windowCount => assert.equal(windowCount, 1, 'No popup is open'))
  })

  it('shows Google login in a popup', function() {
    return this.app.client
      .waitForVisible('button=Sign in')
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
