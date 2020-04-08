'use strict'

const optimist = require('optimist')
const isSoundcloudUrl = require('./is-soundcloud-url')

/* eslint prefer-destructuring: off */
module.exports = function options(process, processArgv) {
  const argv = optimist(processArgv || process.argv)
    .boolean('auto-updater')
    .boolean('check-permissions')
    .boolean('developer-tools')
    .boolean('quit-after-last-window')
    .boolean('use-media-keys')
    .default('auto-updater', true)
    .default('auto-updater-base-url', 'https://updates.soundcleod.com')
    .default('check-permissions', true)
    .default('quit-after-last-window', process.platform != 'darwin')
    .default('use-media-keys', false).argv

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
    checkPermissions: argv['check-permissions'],
    useAutoUpdater: argv['auto-updater'],
    userData: argv['user-data-path'],
    useMediaKeys: argv['use-media-keys']
  }
}
