'use strict'

const electron = require('electron')
const menu = require('./menu')
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const globalShortcut = electron.globalShortcut
const Menu = electron.Menu
const MenuItem = electron.MenuItem
const ipcMain = electron.ipcMain
const autoUpdater = electron.autoUpdater
const os = require('os')
const debounce = require('debounce')
const fs = require('fs')
const windowState = require('electron-window-state')
const contextMenu = require('electron-context-menu')
const shell = electron.shell

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

  const mainWindowState = windowState({
    defaultWidth: 1024,
    defaultHeight: 640
  })

  mainWindow = new BrowserWindow({
    x: mainWindowState.x,
    y: mainWindowState.y,
    width: mainWindowState.width,
    height: mainWindowState.height,
    minWidth: 640,
    minHeight: 320,
    webPreferences: {
      nodeIntegration: false,
      preload: `${__dirname}/preload.js`
    }
  })

  mainWindowState.manage(mainWindow)

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

  function goHome() {
    mainWindow.webContents.send('navigate', '/')
  }

  const playPause = () => trigger('Space')

  const nextTrack = () => trigger('J')

  const previousTrack = () => trigger('K')

  globalShortcut.register('MediaPlayPause', () => {
    playPause()
  })

  globalShortcut.register('MediaNextTrack', () => {
    nextTrack()
  })

  globalShortcut.register('MediaPreviousTrack', () => {
    previousTrack()
  })

  menu.events.on('home', () => {
    goHome()
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

  function isLoginURL(url) {
    return [
      /^https:\/\/accounts\.google\.com.*/i,
      /^https:\/\/www.facebook.com\/dialog\/oauth.*/i
    ].some(re => url.match(re))
  }

  mainWindow.webContents.on('new-window', (event, url, frameName, disposition, options) => {
    // Only allow login popups in SoundCleod, everything else open in external browser
    if (url && isLoginURL(url)) {
      // Do not copy these from mainWindow to login popups
      delete options.minWidth
      delete options.minHeight
      options.webPreferences = Object.assign({}, options.webPreferences, {
        preload: `${__dirname}/preload-popup.js`
      })
    } else {
      event.preventDefault()
      shell.openExternal(url)
    }
  })

  function isSoundCloudURL(url) {
    return [
      /^https?:\/\/soundcloud\.com.*/i
    ].some(re => url.match(re))
  }

  mainWindow.webContents.on('will-navigate', (event, url) => {
    if (url && !isSoundCloudURL(url) && !isLoginURL(url)) {
      event.preventDefault()
      shell.openExternal(url)
    }
  })

  mainWindow.webContents.on('did-fail-load', (event, errorCode) => {
    const redirectErrorCode = -3
    if (errorCode != redirectErrorCode)
      mainWindow.loadURL(`file://${__dirname}/error.html`)
  })

  mainWindow.webContents.once('did-start-loading', () => {
    mainWindow.setTitle('Loading soundcloud.com...')
  })

  contextMenu({
    window: mainWindow,
    prepend: params => {
      if (params.mediaType == 'none')
        return [
          {
            label: 'Home',
            click() {
              goHome()
            }
          },
          {
            label: 'Go back',
            enabled: mainWindow.webContents.canGoBack(),
            click() {
              mainWindow.webContents.goBack()
            }
          },
          {
            label: 'Go forward',
            enabled: mainWindow.webContents.canGoForward(),
            click() {
              mainWindow.webContents.goForward()
            }
          }
        ]
    }
  })

  mainWindow.webContents.on('context-menu', event => {
    event.preventDefault()
    const menu = new Menu()
    menu.popup(mainWindow)
  })

  const dockMenu = new Menu()
  dockMenu.append(new MenuItem({
    label: 'Play/Pause',
    click() {
      playPause()
    }
  }))
  dockMenu.append(new MenuItem({
    label: 'Next',
    click() {
      nextTrack()
    }
  }))
  dockMenu.append(new MenuItem({
    label: 'Previous',
    click() {
      previousTrack()
    }
  }))

  app.dock.setMenu(dockMenu)

  mainWindow.loadURL('https://soundcloud.com')
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
