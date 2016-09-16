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

ipcRenderer.on('playPause', () => trigger(32))
ipcRenderer.on('next', () => trigger(74))
ipcRenderer.on('previous', () => trigger(75))
ipcRenderer.on('help', () => trigger(72))
