'use strict'

const { Menu } = require('electron')
const electronContextMenu = require('electron-context-menu')

module.exports = function contextMenu(window, soundcloud) {
  electronContextMenu({
    window: window,
    prepend: params => {
      if (params.mediaType == 'none')
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
  })

  window.webContents.on('context-menu', event => {
    event.preventDefault()
    const menu = new Menu()
    menu.popup(window)
  })
}
