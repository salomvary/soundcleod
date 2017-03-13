'use strict'

const { app, BrowserWindow, ipcMain } = require('electron')

let win

module.exports = function show(parent, soundcloud) {
  if (win) return

  win = new BrowserWindow({
    height: 105,
    modal: true,
    parent,
    resizable: false,
    show: false,
    skipTaskbar: true,
    useContentSize: true,
    width: 520
  })
  win.setMenu(null)
  win.on('closed', () => win = null)
  win.once('ready-to-show', () => win && win.show())
  app.on('before-quit', () => win && win.close())

  ipcMain.on('edit-url', (_, url) => {
    if (win) win.close()
    soundcloud.navigate(url)
  })

  let url = parent.webContents.getURL()
  win.loadURL(`file://${__dirname}/edit-url.html?${encodeURIComponent(url)}`)
}
