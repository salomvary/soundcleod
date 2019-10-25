'use strict'

const { ipcMain } = require('electron')
const Events = require('events')

module.exports = class SoundCloud extends Events {
  constructor(window) {
    super()
    this.window = window
    this.playing = false
    this.trackMetadata = {}
    window.webContents
      .on('media-started-playing', onMediaStartedPlaying.bind(this))
      .on('media-paused', onMediaPaused.bind(this))
    fixFlakyMediaKeys(window)
  }

  playPause() {
    this.trigger('Space')
  }

  play() {
    if (!this.playing) {
      this.playPause()
    }
  }

  pause() {
    if (this.playing) {
      this.playPause()
    }
  }

  likeUnlike() {
    this.trigger('L')
  }

  repost() {
    this.trigger('R')
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
}

function onMediaStartedPlaying() {
  this.playing = true
  getTrackMetadata.call(this).then((trackMetadata) => {
    if (trackMetadata) {
      this.emit('play', trackMetadata)
      if (!compareTrackMetadata(this.trackMetadata, trackMetadata)) {
        this.emit('play-new-track', trackMetadata)
        this.trackMetadata = trackMetadata
      }
    }
  })
}

function onMediaPaused() {
  this.playing = false
  this.emit('pause')
}

function getTrackMetadata() {
  return new Promise((resolve) => {
    ipcMain.once('trackMetadata', (_, trackMetadata) => {
      const title = parseTitle(this.window.getTitle())
      if (title) {
        resolve({ ...title, ...trackMetadata })
      } else {
        resolve()
      }
    })
    this.window.webContents.send('getTrackMetadata')
  })
}

function parseTitle(windowTitle) {
  let titleParts = windowTitle.split(' by ', 2)
  if (titleParts.length == 1) {
    titleParts = windowTitle.split(' in ', 2)
  }
  if (titleParts.length == 2) {
    // Title has " in " in it when not playing but on a playlist page
    const [title, subtitle] = titleParts
    return { title, subtitle }
  }
  return null
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

function compareTrackMetadata(lhs, rhs) {
  return (
    lhs.title == rhs.title &&
    lhs.subtitle == rhs.subtitle &&
    lhs.artworkUrl == rhs.artworkUrl
  )
}
