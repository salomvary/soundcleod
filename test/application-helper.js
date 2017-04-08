'use strict'

const { Application } = require('spectron')
const tmp = require('tmp')

const defaultArgs = [
  '--no-auto-updater',
  '--developer-tools',
  '--quit-after-last-window'
]

module.exports = function ({ baseURL } = {}) {
  beforeEach('start application', function () {
    // Start each test with a blank user profile
    this.userData = tmp.dirSync()

    const { path, args } = entryPoint()

    const appArgs = args
      .concat(defaultArgs)
      .concat('--user-data-path=' + this.userData.name)

    if (baseURL)
      appArgs.push('--base-url=' + baseURL)

    this.app = new Application({
      args: appArgs,
      env: {
        SPECTRON: true
      },
      path,
      // See https://github.com/electron/spectron#node-integration
      requireName: 'electronRequire',
      waitTimeout: 10000
    })

    return this.app.start()
  })

  afterEach('stop application', function () {
    if (this.app && this.app.isRunning())
      return this.app.stop()
    return null
  })
}

function entryPoint() {
  // Allow running both a built app or electron app/main.js
  const path = process.env.SOUNDCLEOD_PATH
  if (path)
    return {
      path,
      args: []
    }
  return {
    /* eslint global-require: off */
    path: require('electron'),
    args: ['app/main.js']
  }
}
