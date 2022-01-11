'use strict'

const {ipcRenderer} = require('electron')

require('./macos-swipe-navigation').register()

// See https://github.com/electron/spectron#node-integration
if (process.env.SPECTRON) {
  window.electronRequire = require
}

let reposted

function subtreeCallback(mutationList) {
  mutationList.forEach((mutation) => {
      //console.log(mutation)
      if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
        if (mutation.target.className.indexOf('sc-button-repost') != -1) {
          if (mutation.target.className.indexOf('sc-button-selected') == -1) {
            if (reposted === undefined || reposted === true) {
              reposted = false
              console.log('UNREPOSTED!!')
              console.log('UNREPOSTED!!')
              console.log('UNREPOSTED!!')
              console.log('UNREPOSTED!!')
              console.log('UNREPOSTED!!')
              ipcRenderer.send('repost', {reposted: false})
            }
          } else if (reposted === undefined || reposted === false) {
            reposted = true
            console.log('REPOSTED!!')
            console.log('REPOSTED!!')
            console.log('REPOSTED!!')
            console.log('REPOSTED!!')
            ipcRenderer.send('repost', {reposted: true})
          }
        }
      }
    }
  )
}

const observer = new MutationObserver(subtreeCallback)
observer.observe(document, {
  childList: true,
  subtree: true,
  attributes: true
})

ipcRenderer.on('getTrackMetadata', ({sender}) => sendTrackMetadata(sender))
ipcRenderer.on('navigate', (_, url) => navigate(url))
ipcRenderer.on('notification', (_, metadata) => showNotification(metadata))

function sendTrackMetadata(sender) {
  const artworkURL = getArtworkURL()
  const trackURL = getTrackURL()
  const isReposted = getReposted()
  sender.send('trackMetadata', {artworkURL, trackURL, isReposted})
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

function getTrackURL() {
  const track = document.querySelector('.playbackSoundBadge__titleLink')
  if (track) {
    const url = `https://soundcloud.com${track.getAttribute('href')}`
    if (url.indexOf('?') === -1) {
      return url
    }
    return url.split('?')[0]
  }
  return null
}

function getReposted() {
  const nowPlaying = document.querySelector('.playing')
  if (nowPlaying) {
    const repostButton = nowPlaying.querySelector('.sc-button-repost')
    if (repostButton) {
      return repostButton.className.indexOf('sc-button-selected') != -1
    }
  }
  return false
}

const {Notification} = window
// Disable SoundCloud's own notifications, because:
// - They are not silent on macOS
// - They are hidden behind a feature flag
delete window.Notification

function showNotification({title, body, icon}) {
  /* eslint no-new: off */
  new Notification(title, {body, icon, silent: true})
}

const {confirm} = window

window.confirm = (message) => {
  // For some bizarre reason SoundCloud calls comfirm() with { string: 'The message' }
  if (message && message.string) {
    return confirm(message.string)
  }
  return confirm(message)
}
