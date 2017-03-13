'use strict'

const { ipcRenderer } = require('electron')

window.onload = onLoad
window.onkeydown = onKeyDown

function onLoad() {
  const form = document.querySelector('form')
  form.onsubmit = onSubmit
  form.onreset = onReset
  const input = document.querySelector('input')
  input.value = decodeURIComponent(location.search.substring(1))
  input.focus()
  input.select()
}

function onSubmit(event) {
  event.preventDefault()
  const input = document.querySelector('input')
  ipcRenderer.send('edit-url', input.value)
}

function onReset(event) {
  event.preventDefault()
  window.close()
}

function onKeyDown(event) {
  if (event.key == 'Escape') window.close()
}
