'use strict'

const applicationHelper = require('./application-helper')
const assert = require('assert')

describe('Application launch', function() {
  applicationHelper()

  it('shows main window', function() {
    return this.app.client.getWindowCount().then((count) => {
      assert.equal(count, 1)
    })
  })
})
