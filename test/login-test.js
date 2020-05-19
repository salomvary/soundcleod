'use strict'

const applicationHelper = require('./application-helper')
const assert = require('assert')

describe('Logging in', function() {
  applicationHelper()

  it('shows Facebook login in a popup', function() {
    return (
      this.app.client
        // Click sign in button
        .waitForVisible('button=Sign in')
        .element('#content')
        .click('button=Sign in')
        // Wait for the modal to show up
        .waitForVisible('.modal')
        // Switch to the iframe inside the modal that contains the actual login buttons
        .element('.modal iframe')
        .then((iframe) => this.app.client.frame(iframe.value))
        // Click the Facebook button once rendered
        .waitForVisible('button=Continue with Facebook')
        .click('button=Continue with Facebook')
        // Wait for new window(s) to open
        .waitUntil(() =>
          this.app.client.getWindowCount().then((count) => count > 1)
        )
        .then(() => this.app.client.getWindowCount())
        .then((windowCount) => assert.equal(windowCount, 2, 'Opened a popup'))
    )
  })

  it('shows Google login in a popup', function() {
    return (
      this.app.client
        // Click sign in button
        .waitForVisible('button=Sign in')
        .element('#content')
        .click('button=Sign in')
        // Wait for the modal to show up
        .waitForVisible('.modal')
        // Switch to the iframe inside the modal that contains the actual login buttons
        .element('.modal iframe')
        .then((iframe) => this.app.client.frame(iframe.value))
        // Click the Google button once rendered
        .waitForVisible('button=Continue with Google')
        .click('button=Continue with Google')
        // Wait for new window(s) to open
        .waitUntil(() =>
          this.app.client.getWindowCount().then((count) => count > 1)
        )
        .then(() => this.app.client.getWindowCount())
        .then((windowCount) => assert.equal(windowCount, 2, 'Opened a popup'))
    )
  })
})
