'use strict'

const { shell } = require('electron')

module.exports = function windowOpenPolicy(app) {
  app.on('browser-window-created', (_, window) => applyPolicy(window))
}

function applyPolicy(window) {
  window.webContents.on('new-window', onNewWindow)
  window.webContents.on('will-navigate', onWillNavigate)
}

function onNewWindow(event, url, frameName, disposition, options) {
  // Looks like disposition is 'new-window' on window.open and 'foreground-tab' on
  // links with target=_blank. The behavior is not very well documented in Electron:
  // http://electron.atom.io/docs/api/web-contents/#event-new-window
  //
  // What we want here is:
  // - Open share popups within the app
  // - Open login popups within the app
  // - Open everything else in the system browser
  //
  // Assuming nothing else than share and login use window.open, we are only
  // checking disposition here.
  if (disposition == 'new-window') {
    // Do not copy these from mainWindow to login popups
    /* eslint no-param-reassign: off */
    delete options.minWidth
    delete options.minHeight
    options.webPreferences = {
      ...options.webPreferences,
      preload: `${__dirname}/preload-popup.js`
    }
  } else {
    event.preventDefault()
    shell.openExternal(url)
  }
}

function onWillNavigate(event, url) {
  if (url && !isSoundCloudURL(url) && !isLoginURL(url)) {
    event.preventDefault()
    shell.openExternal(url)
  }
}

function isLoginURL(url) {
  return [
    /^https:\/\/accounts\.google\.com.*/i,
    /^https:\/\/www.facebook.com\/.*\/oauth.*/i
  ].some((re) => url.match(re))
}

function isSoundCloudURL(url) {
  return [/^https?:\/\/soundcloud\.com.*/i].some((re) => url.match(re))
}
