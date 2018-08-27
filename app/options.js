'use strict'

const optimist = require('optimist')
const isSoundcloudUrl = require('./is-soundcloud-url')

/* eslint prefer-destructuring: off */
module.exports = function options(process) {
  const argv = optimist(process.argv)
    .boolean('auto-updater')
    .boolean('developer-tools')
    .boolean('quit-after-last-window')
    .default('auto-updater', true)
    .default('auto-updater-base-url', 'https://updates.soundcleod.com')
    .default('quit-after-last-window', process.platform != 'darwin')
    .argv

  // process.argv starts with [SoundCleod] or [Electron, app.js], skip these
  // and get the first non-hyphenated argument
  const launchUrl = argv._[process.defaultApp ? 2 : 1]

  return {
    autoUpdaterBaseUrl: argv['auto-updater-base-url'],
    baseUrl: argv['base-url'],
    developerTools: argv['developer-tools'],
    launchUrl: isSoundcloudUrl(launchUrl) ? launchUrl : undefined,
    profile: argv.profile,
    quitAfterLastWindow: argv['quit-after-last-window'],
    useAutoUpdater: argv['auto-updater'],
    userData: argv['user-data-path']
  }
}
