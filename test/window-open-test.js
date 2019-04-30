'use strict'

const applicationHelper = require('./application-helper')
const assert = require('assert')

describe('Opening windows', function() {
  const soundcleodURL = `file://${__dirname}/window-open.html`

  applicationHelper({ baseURL: soundcleodURL })

  it('opens external link in browser', function() {
    return this.app.client
      .click('=external no target')
      .then(() => this.app.client.getWindowCount())
      .then((count) => assert.equal(count, 1, 'opened no new window'))
    // Should verify URL, but:
    // https://github.com/electron/spectron/issues/64
    // .then(() => this.app.webContents.getURL())
    // .then(url => assert.equal(url, soundcleodURL))
  })

  xit('opens internal link in main window', function() {
    return this.app.client
      .click('=internal no target')
      .then(() => this.app.client.getWindowCount())
      .then((count) => assert.equal(count, 1, 'opened no new window'))
    // Should verify URL, but:
    // https://github.com/electron/spectron/issues/64
    // .then(() => this.app.webContents.getURL())
    // .then(url => assert.equal(url, 'https://soundcloud.com/robots.txt'))
  })

  xit('opens Facebook login in main window', function() {
    // This test never completes since recently (2017-01-14)
    return this.app.client
      .click('=Facebook login')
      .then(() => this.app.client.getWindowCount())
      .waitForExist('#facebook')
      .then((count) => assert.equal(count, 1, 'opened no new window'))
  })

  xit('opens window.open with no options in browser', function() {
    return this.app.client
      .click('=window.open no options')
      .then(() => this.app.client.getWindowCount())
      .then((count) => assert.equal(count, 1, 'opened no new window'))
    // Should verify URL, but:
    // https://github.com/electron/spectron/issues/64
    // .then(() => this.app.webContents.getURL())
    // .then(url => assert.equal(url, soundcleodURL))
  })

  it('opens window.open with options in popup', function() {
    return this.app.client
      .click('=window.open with options')
      .waitUntil(() =>
        this.app.client.getWindowCount().then((count) => count > 1)
      )
      .then(() => this.app.client.getWindowCount())
      .then((count) => assert.equal(count, 2, 'opened new window'))
    // Should verify URL, but:
    // https://github.com/electron/spectron/issues/64
    // .then(() => this.app.webContents.getURL())
    // .then(url => assert.equal(url, soundcleodURL))
  })
})
