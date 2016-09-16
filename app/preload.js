'use strict'

const {ipcRenderer} = require('electron')

function trigger(keyCode) {
  const keyDown = new Event('keydown')
  keyDown.keyCode = keyCode
  document.dispatchEvent(keyDown)

  const keyUp = new Event('keyup')
  keyUp.keyCode = keyCode
  document.dispatchEvent(keyUp)
}

function navigate(url) {
  history.replaceState(null, null, url)
  const e = new Event('popstate')
  window.dispatchEvent(e)
}

ipcRenderer.on('playPause', () => trigger(32))
ipcRenderer.on('next', () => trigger(74))
ipcRenderer.on('previous', () => trigger(75))
ipcRenderer.on('help', () => trigger(72))
ipcRenderer.on('isPlaying', (event) => {
  const isPlaying = !!document.querySelector('.playing')
  event.sender.send('isPlaying', isPlaying)
})
ipcRenderer.on('navigate', (_, url) => {
  navigate(url)
})
ipcRenderer.on('notification', (_, title, body) => {
  new Notification(title, { body, silent: true })
})
