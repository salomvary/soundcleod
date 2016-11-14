'use strict'

const assert = require('assert')
const { Application } = require('spectron')

describe('Opening windows', function() {
  this.timeout(30000)

  const soundcleodURL = `file://${__dirname}/window-open.html`

  beforeEach(function() {
    this.app = new Application({
      args: [
        'app/main.js' ,
        '--profile=test',
        '--no-auto-updater',
        '--developer-tools',
        '--base-url=' + soundcleodURL
      ],
      env: {
        SPECTRON: true
      },
      path: require('electron'),
      requireName: 'electronRequire',
      waitTimeout: 10000
    })
    return this.app.start()
  })

  afterEach(function() {
    if (this.app && this.app.isRunning())
      return this.app.stop()
  })

  it('opens external link in browser', function() {
    return this.app.client
      .click('=external no target')
      .then(() => this.app.client.getWindowCount())
      .then(count => assert.equal(count, 1, 'opened no new window'))
      // Should verify URL, but:
      // https://github.com/electron/spectron/issues/64
      //.then(() => this.app.webContents.getURL())
      //.then(url => assert.equal(url, soundcleodURL))
  })

  it('opens internal link in main window', function() {
    return this.app.client
      .click('=internal no target')
      .then(() => this.app.client.getWindowCount())
      .then(count => assert.equal(count, 1, 'opened no new window'))
      // Should verify URL, but:
      // https://github.com/electron/spectron/issues/64
      //.then(() => this.app.webContents.getURL())
      //.then(url => assert.equal(url, 'https://soundcloud.com/robots.txt'))
  })

  it('opens Facebook login in main window', function() {
    return this.app.client
      .click('=Facebook login')
      .then(() => this.app.client.getWindowCount())
      .waitForExist('#facebook')
      .then(count => assert.equal(count, 1, 'opened no new window'))
  })

  xit('opens window.open with no options in browser', function() {
    return this.app.client
      .click('=window.open no options')
      .then(() => this.app.client.getWindowCount())
      .then(count => assert.equal(count, 1, 'opened no new window'))
      // Should verify URL, but:
      // https://github.com/electron/spectron/issues/64
      //.then(() => this.app.webContents.getURL())
      //.then(url => assert.equal(url, soundcleodURL))
  })

  it('opens window.open with options in popup', function() {
    return this.app.client
      .click('=window.open with options')
      .waitUntil(() => this.app.client.getWindowCount().then(count => count > 1))
      .then(() => this.app.client.getWindowCount())
      .then(count => assert.equal(count, 2, 'opened new window'))
      // Should verify URL, but:
      // https://github.com/electron/spectron/issues/64
      //.then(() => this.app.webContents.getURL())
      //.then(url => assert.equal(url, soundcleodURL))
  })
})