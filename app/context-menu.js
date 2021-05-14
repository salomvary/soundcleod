'use strict'

const electronContextMenu = require('electron-context-menu')

const { shell }= require('electron')

module.exports = function contextMenu(window, soundcloud) {
  // TODO: apply context menu to all windows but only add navigation items to main window
  // See https://github.com/sindresorhus/electron-context-menu/pull/25
  electronContextMenu({
    window,
    prepend: (defaultActions, params) => {
      if (params.mediaType == 'none') {
        return menuTemplate(soundcloud)
      }
    },
    append: (defaultActions, params) => [ {
      label: 'Open in Browser',
      after: ['copyLink'],
      visible: params.linkURL.length !== 0 && params.mediaType === 'none',
      click(menuItem) {
        shell.openExternal(menuItem.transform ? menuItem.transform(params.linkURL) : params.linkURL)
      }
    }]
  })
}

function menuTemplate(soundcloud) {
  return [
    {
      label: 'Home',
      click() {
        soundcloud.goHome()
      }
    },
    {
      label: 'Go back',
      enabled: soundcloud.canGoBack(),
      click() {
        soundcloud.goBack()
      }
    },
    {
      label: 'Go forward',
      enabled: soundcloud.canGoForward(),
      click() {
        soundcloud.goForward()
      }
    }
  ]
}