'use strict'

const { app, Menu, shell } = require('electron')
const Events = require('events')

module.exports = function menu(options = {}) {
  return buildMenu(options)
}

function buildMenu(options) {
  const events = new Events()
  const menu = [
    {
      label: 'Edit',
      submenu: [
        {
          label: 'Undo',
          accelerator: 'CmdOrCtrl+Z',
          role: 'undo'
        },
        {
          label: 'Redo',
          accelerator: 'Shift+CmdOrCtrl+Z',
          role: 'redo'
        },
        {
          type: 'separator'
        },
        {
          label: 'Cut',
          accelerator: 'CmdOrCtrl+X',
          role: 'cut'
        },
        {
          label: 'Copy',
          accelerator: 'CmdOrCtrl+C',
          role: 'copy'
        },
        {
          label: 'Paste',
          accelerator: 'CmdOrCtrl+V',
          role: 'paste'
        },
        {
          label: 'Select All',
          accelerator: 'CmdOrCtrl+A',
          role: 'selectall'
        }
      ]
    },
    {
      label: 'View',
      submenu: [
        {
          label: 'Toggle Full Screen',
          accelerator: process.platform == 'darwin' ? 'Ctrl+Command+F' : 'F11',
          click(item, focusedWindow) {
            if (focusedWindow) {
              focusedWindow.setFullScreen(!focusedWindow.isFullScreen())
            }
          }
        },
        {
          label: 'Reload',
          accelerator: 'CmdOrCtrl+R',
          click(item, focusedWindow) {
            if (focusedWindow) {
              focusedWindow.reload()
            }
          }
        }
      ]
    },
    {
      label: 'History',
      submenu: [
        {
          label: 'Home',
          accelerator: 'CmdOrCtrl+Shift+H',
          click() {
            events.emit('home')
          }
        },
        {
          label: 'Back',
          accelerator: 'CmdOrCtrl+Left',
          click() {
            events.emit('back')
          }
        },
        {
          label: 'Forward',
          accelerator: 'CmdOrCtrl+Right',
          click() {
            events.emit('forward')
          }
        }
      ]
    },
    {
      label: 'Controls',
      submenu: [
        {
          label: 'Play/Pause',
          accelerator: 'Space',
          click() {
            events.emit('playPause')
          }
        },
        {
          label: 'Like',
          accelerator: 'L',
          click() {
            events.emit('likeUnlike')
          }
        },
        {
          label: 'Repost',
          accelerator: 'R',
          click() {
            events.emit('repost')
          }
        },
        {
          label: 'Next',
          accelerator: 'Shift+Right',
          click() {
            events.emit('nextTrack')
          }
        },
        {
          label: 'Previous',
          accelerator: 'Shift+Left',
          click() {
            events.emit('previousTrack')
          }
        }
      ]
    },
    {
      label: 'Window',
      role: 'window',
      submenu: [
        {
          label: 'Main Window',
          accelerator: 'CmdOrCtrl+1',
          click() {
            events.emit('main-window')
          }
        },
        {
          label: 'Minimize',
          accelerator: 'CmdOrCtrl+M',
          role: 'minimize'
        },
        {
          label: 'Close',
          accelerator: 'CmdOrCtrl+W',
          role: 'close'
        }
      ]
    },
    {
      label: 'Help',
      role: 'help',
      submenu: [
        {
          label: 'Learn More',
          click() {
            shell.openExternal('http://soundcleod.com')
          }
        },
        {
          label: 'About SoundCleod',
          click() {
            events.emit('about')
          },
          visible: process.platform !== 'darwin'
        }
      ]
    }
  ]

  if (options.developerTools) {
    menu[1].submenu.push({
      label: 'Toggle Developer Tools',
      accelerator:
        process.platform == 'darwin' ? 'Alt+Command+I' : 'Ctrl+Shift+I',
      click(item, focusedWindow) {
        if (focusedWindow) {
          focusedWindow.toggleDevTools()
        }
      }
    })
  }

  if (process.platform == 'darwin') {
    const { name } = app
    menu.unshift({
      label: name,
      submenu: [
        {
          label: 'About ' + name,
          role: 'about'
        },
        {
          type: 'separator'
        },
        {
          label: 'Services',
          role: 'services',
          submenu: []
        },
        {
          type: 'separator'
        },
        {
          label: 'Hide ' + name,
          accelerator: 'Command+H',
          role: 'hide'
        },
        {
          label: 'Hide Others',
          accelerator: 'Command+Alt+H',
          role: 'hideothers'
        },
        {
          label: 'Show All',
          role: 'unhide'
        },
        {
          type: 'separator'
        },
        {
          label: 'Quit',
          accelerator: 'Command+Q',
          click() {
            app.quit()
          }
        }
      ]
    })
    // Window menu.
    menu[3].submenu.push(
      {
        type: 'separator'
      },
      {
        label: 'Bring All to Front',
        role: 'front'
      }
    )
  } else {
    menu.unshift({
      label: 'File',
      submenu: [
        {
          label: 'Quit',
          accelerator: 'Ctrl+Q',
          click() {
            app.quit()
          }
        }
      ]
    })
  }

  const built = Menu.buildFromTemplate(menu)
  built.events = events
  return built
}
