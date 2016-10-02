'use strict'

const {ipcRenderer} = require('electron')

function navigate(url) {
  history.replaceState(null, null, url)
  const e = new Event('popstate')
  window.dispatchEvent(e)
}

ipcRenderer.on('isPlaying', (event) => {
  const isPlaying = !!document.querySelector('.playing')
  event.sender.send('isPlaying', isPlaying)
})
ipcRenderer.on('navigate', (_, url) => {
  navigate(url)
})

const Notification = window.Notification
ipcRenderer.on('notification', (_, title, body) => {
  new Notification(title, { body, silent: true })
})
// Disable SoundCloud's own notifications, because:
// - They are not silent on macOS
// - They are hidden behind a feature flag
delete window.Notification

const confirm = window.confirm

window.confirm = function(message) {
  // For some bizarre reason SoundCloud calls comfirm() with { string: 'The message' }
  if (message && message.string)
    return confirm(message.string)
  else
    return confirm(message)
}

// Facebook login pupup fails to close and notify the main SoundCloud window
// after a successful login because it relies on window.opener.frames being
// available in the popup.
//
// This is an ugly and fragile hack that utilizes the fact that SoundCloud
// provides a popup-less Facebook login link fallback in case the Facebook JS
// SDK is not available on the page (eg. blocked by the browser)
window.addEventListener('DOMContentLoaded', () => {
  const css = document.createElement('style')
  css.type = 'text/css'
  css.innerHTML = '.signinInitialStep_fbButton { display: none !important }'
    + '.signinInitialStep_fbLink { display: block !important }'
  document.body.appendChild(css)
})
