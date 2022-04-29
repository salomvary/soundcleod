'use strict'

const {ipcRenderer} = require('electron')

require('./macos-swipe-navigation').register()

// See https://github.com/electron/spectron#node-integration
if (process.env.SPECTRON) {
  window.electronRequire = require
}

let isReposted = false

function subtreeCallback(mutationList) {
  mutationList.forEach((mutation) => {
    // console.log(mutation)
    if (mutation.type === 'attributes' && mutation.attributeName === 'class') {
      if (mutation.target.className.indexOf('sc-button-repost') !== -1) {
        const oldReposted = isReposted
        isReposted = getReposted()
        if (oldReposted === undefined || isReposted !== oldReposted) {
          ipcRenderer.send('repost', {reposted: isReposted})
        }
      }
    } else if (mutation.type === 'childList' && mutation.target !== undefined) {
      if (mutation.target.id.indexOf('gritter-notice-wrapper') !== -1) {
        // reposted popup
        if (mutation.addedNodes.length > 0
          && mutation.addedNodes[0].innerText.indexOf('was reposted to')
          !== -1) {
          const oldReposted = isReposted
          isReposted = true
          if (oldReposted === undefined || isReposted !== oldReposted) {
            ipcRenderer.send('repost', {reposted: isReposted})
          }
        }
      }
    }
  })
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
  isReposted = getReposted()
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
  // get track from the track's page
  const gritter = document.querySelector('.gritter-with-image p')
  if (gritter != null) {
    if (gritter.innerText.indexOf('was reposted to') !== -1) {
      return true
    }
  }

  let nowPlaying = document.querySelector('.listenEngagement__footer')
  if (!nowPlaying) {
    // get track from stream
    nowPlaying = document.querySelector('.playing')
  } else {
    // on the track's main page, check if it's playing or not
    const playButton = document.querySelector('.fullHero__title').querySelector(
      '.sc-button-pause')
    if (!playButton) {
      return false
    }
  }
  if (nowPlaying) {
    const repostButton = nowPlaying.querySelector('.sc-button-repost')
    if (repostButton) {
      return repostButton.className.indexOf('sc-button-selected') !== -1
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
