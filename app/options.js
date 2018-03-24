'use strict'

const optimist = require('optimist')
const url = require('url')

/* eslint prefer-destructuring: off */
module.exports = function options(process) {
  const argv = optimist(process.argv)
    .default('auto-updater', true)
    .default('auto-updater-base-url', 'https://updates.soundcleod.com')
    .default('quit-after-last-window', process.platform != 'darwin')
    .argv
  const arg = optimist(process.argv).argv._
  const {protocol, hostname} = url.parse(arg[2])

  var startUrl
  if ((protocol === 'https:' || protocol === 'http:') && hostname === 'soundcloud.com') {
    startUrl = arg[2]
  }

  return {
    autoUpdaterBaseUrl: argv['auto-updater-base-url'],
    baseUrl: argv['base-url'],
    developerTools: argv['developer-tools'],
    profile: argv.profile,
    quitAfterLastWindow: argv['quit-after-last-window'],
    useAutoUpdater: argv['auto-updater'],
    userData: argv['user-data-path'],
    startUrl: startUrl
  }
}
