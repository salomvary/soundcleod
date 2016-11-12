'use strict'

const electron = require('electron')
const contextMenu = require('./context-menu')
const autoUpdater = require('./auto-updater')
const dockMenu = require('./dock-menu')
const errorHandlers = require('./error-handlers')
const mainMenu = require('./menu')
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const globalShortcut = electron.globalShortcut
const Menu = electron.Menu
const windowState = require('electron-window-state')
const shell = electron.shell
const SoundCloud = require('./soundcloud')

var mainWindow = null

const argv = require('optimist')
  .default('auto-updater', true)
  .argv

const baseUrl = argv['base-url']
const developerTools = argv['developer-tools']
const profile = argv['profile']
const quitAfterLastWindow = argv['quit-after-last-window']
const useAutoUpdater = argv['auto-updater']
const userData = argv['user-data-path']

if (userData)
  app.setPath('userData', userData)
else if (profile)
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

if (useAutoUpdater) autoUpdater()

app.on('activate', () => {
  if (mainWindow) mainWindow.show()
})

app.on('ready', function() {
  const menu = mainMenu({ developerTools })
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
  if (process.platform == 'darwin')
    dockMenu(soundcloud)

  mainWindowState.manage(mainWindow)

  mainWindow.on('close', (event) => {
    // Due to (probably) a bug in Spectron this prevents quitting
    // the app in tests:
    // https://github.com/electron/spectron/issues/137
    if (!quitting && quitAfterLastWindow) {
      event.preventDefault()
      mainWindow.hide()
    }
  })

  mainWindow.on('closed', function() {
    if (process.platform !== 'darwin')
      app.quit()
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
    if (disposition == 'new-window') {
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

  mainWindow.loadURL(getUrl())
})

function getUrl() {
  if (baseUrl)
    return baseUrl
  else
    return 'https://soundcloud.com'
}
