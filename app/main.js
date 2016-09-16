'use strict'

const electron = require('electron')
const menu = require('./menu')
const app = electron.app
const BrowserWindow = electron.BrowserWindow
const globalShortcut = electron.globalShortcut
const Menu = electron.Menu
const ipcMain = electron.ipcMain

var mainWindow = null

const profile = process.env.SOUNDCLEOD_PROFILE
if (profile)
  app.setPath('userData', app.getPath('userData') + ' ' + profile)

app.on('window-all-closed', function() {
  app.quit()
})

app.on('ready', function() {
  Menu.setApplicationMenu(Menu.buildFromTemplate(menu))

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
  mainWindow.on('closed', function() {
    mainWindow = null
  })

  globalShortcut.register('MediaPlayPause', () => {
    mainWindow.webContents.send('playPause')
  })

  globalShortcut.register('MediaNextTrack', () => {
    mainWindow.webContents.send('next')
  })

  globalShortcut.register('MediaPreviousTrack', () => {
    mainWindow.webContents.send('previous')
  })

  require('electron').powerMonitor.on('suspend', () => {
    ipcMain.once('isPlaying', (_, isPlaying) => {
      if (isPlaying)
        mainWindow.webContents.send('playPause')
    })
    mainWindow.webContents.send('isPlaying')
  })
})
