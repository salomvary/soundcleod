'use strict'

const electron = require('electron')
const contextMenu = require('./context-menu')
const errorHandlers = require('./error-handlers')
const menu = require('./menu')
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const globalShortcut = electron.globalShortcut
const Menu = electron.Menu
const MenuItem = electron.MenuItem
const autoUpdater = electron.autoUpdater
const os = require('os')
const fs = require('fs')
const windowState = require('electron-window-state')
const shell = electron.shell
const SoundCloud = require('./soundcloud')

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

  const soundcloud = new SoundCloud(mainWindow)
  contextMenu(mainWindow, soundcloud)
  errorHandlers(mainWindow)

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

  globalShortcut.register('MediaPlayPause', () => {
    soundcloud.playPause()
  })

  globalShortcut.register('MediaNextTrack', () => {
    soundcloud.nextTrack()
  })

  globalShortcut.register('MediaPreviousTrack', () => {
    soundcloud.previousTrack()
  })

  menu.events.on('home', () => {
    soundcloud.goHome()
  })

  menu.events.on('back', () => {
    soundcloud.goBack()
  })

  menu.events.on('forward', () => {
    soundcloud.goForward()
  })

  menu.events.on('main-window', () => {
    mainWindow.show()
  })

  require('electron').powerMonitor.on('suspend', () => {
    soundcloud.isPlaying().then(isPlaying => {
      if (isPlaying)
        soundcloud.playPause()
    })
  })

  soundcloud.on('play', (title, subtitle) => {
    mainWindow.webContents.send('notification', title, subtitle)
  })

  function isLoginURL(url) {
    return [
      /^https:\/\/accounts\.google\.com.*/i,
      /^https:\/\/www.facebook.com\/dialog\/oauth.*/i
    ].some(re => url.match(re))
  }

  mainWindow.webContents.on('new-window', (event, url, frameName, disposition, options) => {
    // Looks like disposition is 'new-window' on window.open and 'foreground-tab' on
    // links with target=_blank. The behavior is not very well documented in Electron:
    // http://electron.atom.io/docs/api/web-contents/#event-new-window
    //
    // What we want here is:
    // - Open share popups within the app
    // - Open login popups within the app
    // - Open everything else in the system browser
    //
    // Assuming nothing else than share and login use window.open, we are only
    // checking disposition here.
    //
    // Interestingly frameName is not set to _blank when clicking on links with
    // target=_blank but it is one some programmatically opened links (eg.
    // "Help forum" from the menu).
    if (disposition == 'new-window' && frameName != '_blank') {
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

  mainWindow.webContents.once('did-start-loading', () => {
    mainWindow.setTitle('Loading soundcloud.com...')
  })

  const dockMenu = new Menu()
  dockMenu.append(new MenuItem({
    label: 'Play/Pause',
    click() {
      soundcloud.playPause()
    }
  }))
  dockMenu.append(new MenuItem({
    label: 'Next',
    click() {
      soundcloud.nextTrack()
    }
  }))
  dockMenu.append(new MenuItem({
    label: 'Previous',
    click() {
      soundcloud.previousTrack()
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
