'use strict'

const { ipcRenderer } = require('electron')

require('./macos-swipe-navigation').register()

// See https://github.com/electron/spectron#node-integration
if (process.env.SPECTRON) {
  window.electronRequire = require
}

ipcRenderer.on('getTrackMetadata', ({ sender }) => sendTrackMetadata(sender))
ipcRenderer.on('navigate', (_, url) => navigate(url))
ipcRenderer.on('notification', (_, metadata) => showNotification(metadata))

function sendTrackMetadata(sender) {
  const artworkURL = getArtworkURL()
  sender.send('trackMetadata', { artworkURL })
}

function navigate(url) {
  window.history.replaceState(null, null, url)
  const e = new Event('popstate')
  window.dispatchEvent(e)
}

function getArtworkURL() {
  const artwork = document.querySelector(
    '.playbackSoundBadge__avatar [aria-role=img]'
  )
  if (artwork) {
    // Extract actual URL from CSS url()
    const match = artwork.style.backgroundImage.match(
      /(?:url\s*\(\s*['"]?)(.*?)(?:['"]?\s*\))/i
    )
    return match && match[1]
  }
  return null
}

const { Notification } = window
// Disable SoundCloud's own notifications, because:
// - They are not silent on macOS
// - They are hidden behind a feature flag
delete window.Notification

function showNotification({ title, body, icon }) {
  /* eslint no-new: off */
  new Notification(title, { body, icon, silent: true })
}

const { confirm } = window

window.confirm = (message) => {
  // For some bizarre reason SoundCloud calls comfirm() with { string: 'The message' }
  if (message && message.string) {
    return confirm(message.string)
  }
  return confirm(message)
}
