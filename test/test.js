'use strict'

const { Application } = require('spectron')
const assert = require('assert')

describe('application launch', function() {

  beforeEach(function() {
    this.timeout(5000)
    this.app = new Application({
      args: [ 'app/main.js' ],
      env: {
        NODE_ENV: 'development',
        SOUNDCLEOD_PROFILE: 'test'
      },
      path: 'node_modules/.bin/electron'
    })
    return this.app.start()
  })

  afterEach(function() {
    if (this.app && this.app.isRunning())
      return this.app.stop()
  })

  it('shows main window', function() {
    return this.app.client.getWindowCount().then((count) => {
      assert.equal(count, 1)
    })
  })

})
