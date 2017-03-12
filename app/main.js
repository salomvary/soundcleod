'use strict'

// Handle the Squirrel.Windows install madnesss
if (require('electron-squirrel-startup')) return

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
const SoundCloud = require('./soundcloud')
const windowOpenPolicy = require('./window-open-policy')
const options = require('./options')

var mainWindow = null
var aboutWindow = null

const {
  autoUpdaterBaseUrl,
  baseUrl,
  developerTools,
  profile,
  quitAfterLastWindow,
  useAutoUpdater,
  userData
} = options(process)

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

if (useAutoUpdater) autoUpdater(autoUpdaterBaseUrl)

windowOpenPolicy(app)

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
    if (!quitting && !quitAfterLastWindow) {
      event.preventDefault()
      mainWindow.hide()
    }
  })

  // For MacOS, disable 'close' and 'minimize' buttons on fullscreen event
  mainWindow.on('enter-full-screen', () => {
    if (process.platform == 'darwin') {
      mainWindow.setMinimizable(false)
      mainWindow.setClosable(false)
    }
  })

  // For MacOS, enable 'close' and 'minimize' buttons on exit-fullscreen event
  mainWindow.on('leave-full-screen', () => {
    if (process.platform == 'darwin') {
      mainWindow.setMinimizable(true)
      mainWindow.setClosable(true)
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

  menu.events.on('playPause', () => {
    soundcloud.playPause()
  })

  menu.events.on('likeUnlike', () => {
    soundcloud.likeUnlike()
  })

  menu.events.on('nextTrack', () => {
    soundcloud.nextTrack()
  })

  menu.events.on('previousTrack', () => {
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
    if (mainWindow.isVisible())
      mainWindow.hide()
    else
      mainWindow.show()
  })

  menu.events.on('about', () => {
    showAbout()
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

function showAbout() {
  if (aboutWindow)
    aboutWindow.show()
  else {
    aboutWindow = new BrowserWindow({
      fullscreen: false,
      fullscreenable: false,
      height: 520,
      maximizable: false,
      resizable: false,
      show: false,
      skipTaskbar: true,
      width: 385,
      modal: true,
      parent: mainWindow
    })
    aboutWindow.setMenu(null)
    aboutWindow.once('ready-to-show', () => {
      aboutWindow.show()
    })
    aboutWindow.on('close', () => {
      aboutWindow = null
    })
    aboutWindow.loadURL(`file://${__dirname}/about.html`)
  }
}
