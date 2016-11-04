'use strict'

const electron = require('electron')
const Events = require('events')
const Menu = electron.Menu
const app = electron.app
const shell = electron.shell

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
        accelerator: (function() {
          if (process.platform == 'darwin')
            return 'Ctrl+Command+F'
          else
            return 'F11'
        })(),
        click: function(item, focusedWindow) {
          if (focusedWindow)
            focusedWindow.setFullScreen(!focusedWindow.isFullScreen())
        }
      },
      {
        label: 'Reload',
        accelerator: 'CmdOrCtrl+R',
        click: function(item, focusedWindow) {
          if (focusedWindow)
            focusedWindow.reload()
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
        accelerator: 'Space'
      },
      {
        label: 'Next',
        accelerator: 'Shift+Right'
      },
      {
        label: 'Previous',
        accelerator: 'Shift+Left'
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
        click: function() { shell.openExternal('http://soundcleod.com') }
      }
    ]
  }
]

if (process.env.NODE_ENV == 'development' || process.env.NODE_ENV == 'test')
  menu[1].submenu.push(
    {
      label: 'Toggle Developer Tools',
      accelerator: (function() {
        if (process.platform == 'darwin')
          return 'Alt+Command+I'
        else
          return 'Ctrl+Shift+I'
      })(),
      click: function(item, focusedWindow) {
        if (focusedWindow)
          focusedWindow.toggleDevTools()
      }
    }
  )

if (process.platform == 'darwin') {
  const name = app.getName()
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
        click: function() { app.quit() }
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
}

module.exports = Menu.buildFromTemplate(menu)
module.exports.events = events
