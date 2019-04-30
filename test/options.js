'use strict'

const assert = require('assert')
const options = require('../app/options')

describe('Parsing options', function() {
  it('returns macOS defaults', function() {
    assert.deepEqual(options({ argv: [], platform: 'darwin' }), {
      autoUpdaterBaseUrl: 'https://updates.soundcleod.com',
      baseUrl: undefined,
      checkPermissions: true,
      developerTools: false,
      launchUrl: undefined,
      profile: undefined,
      quitAfterLastWindow: false,
      useAutoUpdater: true,
      userData: undefined
    })
  })

  it('returns defaults', function() {
    assert.deepEqual(options({ argv: [], platform: 'linux' }), {
      autoUpdaterBaseUrl: 'https://updates.soundcleod.com',
      baseUrl: undefined,
      checkPermissions: true,
      developerTools: false,
      launchUrl: undefined,
      profile: undefined,
      quitAfterLastWindow: true,
      useAutoUpdater: true,
      userData: undefined
    })
  })

  it('returns overridden autoUpdaterBaseUrl', function() {
    assert.deepEqual(
      options({ argv: ['', '--auto-updater-base-url=test'] })
        .autoUpdaterBaseUrl,
      'test'
    )
  })
})
