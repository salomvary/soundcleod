'use strict'

const applicationHelper = require('./application-helper')
const assert = require('assert')

describe('Logging in', function() {
  applicationHelper()

  it('shows Facebook login in a popup', function() {
    return this.app.client
      .waitForVisible('button=Sign in')
      .element('#content')
      .click('button=Sign in')
      .waitForVisible('button=Continue with Facebook')
      .click('button=Continue with Facebook')
      .waitUntil(() =>
        this.app.client.getWindowCount().then((count) => count > 1)
      )
      .then(() => this.app.client.getWindowCount())
      .then((windowCount) => assert.equal(windowCount, 2, 'Opened a popup'))
  })

  it('shows Google login in a popup', function() {
    return this.app.client
      .waitForVisible('button=Sign in')
      .element('#content')
      .click('button=Sign in')
      .waitForVisible('button=Continue with Google')
      .click('button=Continue with Google')
      .waitUntil(() =>
        this.app.client.getWindowCount().then((count) => count > 1)
      )
      .then(() => this.app.client.getWindowCount())
      .then((windowCount) => assert.equal(windowCount, 2, 'Opened a popup'))
  })
})
