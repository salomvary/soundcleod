'use strict'

const optimist = require('optimist')

module.exports = function options(process) {
  const argv = optimist(process.argv)
    .default('auto-updater', true)
    .default('auto-updater-base-url', 'https://updates.soundcleod.com')
    .default('quit-after-last-window', process.platform != 'darwin')
    .argv

  return {
    autoUpdaterBaseUrl: argv['auto-updater-base-url'],
    baseUrl: argv['base-url'],
    developerTools: argv['developer-tools'],
    profile: argv.profile,
    quitAfterLastWindow: argv['quit-after-last-window'],
    useAutoUpdater: argv['auto-updater'],
    userData: argv['user-data-path']
  }
}
