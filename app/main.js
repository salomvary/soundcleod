'use strict'

const electron = require('electron')
const menu = require('./menu')
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const globalShortcut = electron.globalShortcut
const Menu = electron.Menu
const ipcMain = electron.ipcMain
const autoUpdater = electron.autoUpdater
const os = require('os')
const debounce = require('debounce')
const fs = require('fs')

var mainWindow = null

const profile = process.env.SOUNDCLEOD_PROFILE
if (profile)
  app.setPath('userData', app.getPath('userData') + ' ' + profile)

var quitting = false

app.on('before-quit', function() {
  quitting = true
})

const shouldQuit = app.makeSingleInstance(() => {
  if (mainWindow) {
    if (mainWindow.isMinimized()) mainWindow.restore()
    mainWindow.show()
    mainWindow.focus()
  }
})

if (shouldQuit) app.quit()

app.on('activate', () => {
  if (mainWindow) mainWindow.show()
})

app.on('ready', function() {
  Menu.setApplicationMenu(menu)

  mainWindow = new BrowserWindow({
    width: 1290,
    height: 800,
    minWidth: 1024,
    minHeight: 760,
    webPreferences: {
      nodeIntegration: false,
      preload: `${__dirname}/preload.js`
    }
  })

  mainWindow.loadURL('https://soundcloud.com')

  mainWindow.on('close', (event) => {
    if (!quitting) {
      event.preventDefault()
      mainWindow.hide()
    }
  })

  mainWindow.on('closed', function() {
    mainWindow = null
  })

  function trigger(keyCode) {
    mainWindow.webContents.sendInputEvent({
      type: 'keyDown',
      keyCode
    })

    // Triggering keyUp immediately confuses SoundCloud
    setTimeout(() => {
      mainWindow.webContents.sendInputEvent({
        type: 'keyUp',
        keyCode
      })
    }, 50)
  }

  const playPause = () => trigger('Space')

  globalShortcut.register('MediaPlayPause', () => {
    playPause()
  })

  globalShortcut.register('MediaNextTrack', () => {
    trigger('J')
  })

  globalShortcut.register('MediaPreviousTrack', () => {
    trigger('K')
  })

  menu.events.on('home', () => {
    mainWindow.webContents.send('navigate', '/')
  })

  menu.events.on('back', () => {
    mainWindow.webContents.goBack()
  })

  menu.events.on('forward', () => {
    mainWindow.webContents.goForward()
  })

  menu.events.on('main-window', () => {
    mainWindow.show()
  })

  require('electron').powerMonitor.on('suspend', () => {
    ipcMain.once('isPlaying', (_, isPlaying) => {
      if (isPlaying)
        playPause()
    })
    mainWindow.webContents.send('isPlaying')
  })

  const titleDebounceWaitMs = 200

  mainWindow.on('page-title-updated', debounce((_, title) => {
    var titleParts = title.split(' by ', 2)
    if (titleParts.length == 1)
      titleParts = title.split(' in ', 2)
    if (titleParts.length == 2) {
      // Title has " in " in it when not playing but on a playlis page
      ipcMain.once('isPlaying', (_, isPlaying) => {
        if (isPlaying)
          mainWindow.webContents.send('notification', titleParts[0], titleParts[1])
      })
      mainWindow.webContents.send('isPlaying')
    }
  }), titleDebounceWaitMs)

  mainWindow.webContents.on('new-window', (event, url, frameName, disposition, options) => {
    // Do not copy these from mainWindow to login popups
    delete options.minWidth
    delete options.minHeight
    if (options.webPreferences)
      delete options.webPreferences.preload
  })
})

function maybeStartAutoUpdater(callback) {
  if (process.env.NODE_ENV == 'development')
    console.log('Disabled automatic updates in development mode.')
  else
    // Test if updates can actually be installed, see also:
    // https://github.com/electron/electron/issues/7357
    fs.access(app.getPath('exe'), fs.constants.W_OK, err => {
      if (err && err.code == 'EROFS')
        console.log('Disabled automatic updates on a read-only file system.')
      else
        callback()
    })
}

maybeStartAutoUpdater(() => {
  const platform = os.platform() + '_' + os.arch()
  const version = app.getVersion()

  autoUpdater.setFeedURL(`https://soundcleod-updates.herokuapp.com/update/${platform}/${version}`)

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
})
