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
      ipcMain.once('isPlaying', (_, isPlaying) => {
        resolve(isPlaying)
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
      this.isPlaying().then(isPlaying => {
        if (isPlaying)
          this.emit('play', titleParts[0], titleParts[1])
      })
  }
}


