'use strict'

const debounce = require('debounce')
const { ipcMain } = require('electron')
const Events = require('events')

const titleDebounceWaitMs = 200

module.exports = class SoundCloud extends Events {
  constructor(window) {
    super()
    this.window = window
    window.on('page-title-updated', debounce((_, title) => {
      this.onTitleUpdated(_, title)
    }), titleDebounceWaitMs)
    fixFlakyMediaKeys(window)
  }

  playPause() {
    this.trigger('Space')
  }

  nextTrack() {
    this.trigger('J')
  }

  previousTrack() {
    this.trigger('K')
  }

  goHome() {
    this.window.webContents.send('navigate', '/')
  }

  canGoBack() {
    return this.window.webContents.canGoBack()
  }

  canGoForward() {
    return this.window.webContents.canGoForward()
  }

  goBack() {
    this.window.webContents.goBack()
  }

  goForward() {
    this.window.webContents.goForward()
  }

  isPlaying() {
    return new Promise(resolve => {
      ipcMain.once('isPlaying', (_, isPlaying, icon) => {
        resolve({isPlaying, icon})
      })
      this.window.webContents.send('isPlaying')
    })
  }

  trigger(keyCode) {
    this.window.webContents.sendInputEvent({
      type: 'keyDown',
      keyCode
    })

    this.window.webContents.sendInputEvent({
      type: 'keyUp',
      keyCode
    })
  }

  onTitleUpdated(_, title) {
    var titleParts = title.split(' by ', 2)
    if (titleParts.length == 1)
      titleParts = title.split(' in ', 2)
    if (titleParts.length == 2)
      // Title has " in " in it when not playing but on a playlis page
      this.isPlaying().then(obj => {
        const isPlaying = obj.isPlaying
        const icon = obj.icon
        if (isPlaying)
          this.emit('play', titleParts[0], titleParts[1], icon)
      })
  }
}

/*
 * There is apparently no guarantee on a keydown event will be followed by a
 * keyup of the same key. This for example happens when the application is
 * switched away from using keyboard shortcuts (Cmd+tab or Cmd+w). In this case
 * only the keydown events are sent, the keyup is never received by the window.
 * Same behavior exists in real browsers too, most likely not a bug in Electron.
 *
 * However this lack of keyup events behavior confuses SoundCloud and keyboard
 * shortcuts temporarily stop functioning (until a keyup event is sent again).
* This is an attempt to workaround the situation.
 */
function fixFlakyMediaKeys(mainWindow) {
  mainWindow.on('blur', () => {
    mainWindow.webContents.sendInputEvent({
      type: 'keyUp',
      // anything should do it, trying something unused as a shortcut
      keyCode: '|'
    })
  })
}
