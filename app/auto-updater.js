'use strict'

const { app, autoUpdater } = require('electron')
const fs = require('fs')
const os = require('os')

module.exports = function maybeStartAutoUpdater(baseUrl) {
  checkAutoUpdater(() => startAutoUpdater(baseUrl))
}

function checkAutoUpdater(callback) {
  // Test if updates can actually be installed, see also:
  // https://github.com/electron/electron/issues/7357
  fs.access(app.getPath('exe'), fs.constants.W_OK, err => {
    if (err && err.code == 'EROFS')
      console.log('Disabled automatic updates on a read-only file system.')
    else
      callback()
  })
}

function startAutoUpdater(baseUrl) {
  const platform = os.platform() + '_' + os.arch()
  const version = app.getVersion()

  autoUpdater.setFeedURL(`${baseUrl}/update/${platform}/${version}`)

  autoUpdater.on('checking-for-update', () => console.log('autoUpdater checking for update'))
  autoUpdater.on('update-available', () => console.log('autoUpdater update available'))
  autoUpdater.on('update-downloaded', () => console.log('autoUpdater update downloaded'))

  const oneHourInMs = 60 * 60 * 1000

  autoUpdater.on('update-not-available', () => {
    console.log('autoUpdater update not available')
    // Check again in an hour
    setTimeout(() => autoUpdater.checkForUpdates(), oneHourInMs)
  })

  autoUpdater.on('error', error => {
    console.error('autoUpdater error', error)
    // Check again in an hour
    setTimeout(() => autoUpdater.checkForUpdates(), oneHourInMs)
  })

  autoUpdater.checkForUpdates()
}
