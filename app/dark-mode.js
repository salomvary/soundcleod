'use strict'

const fs = require('fs')
const path = require('path')
const { promisify } = require('util')

const readFile = promisify(fs.readFile)

module.exports = function darkMode(mainWindow) {
  mainWindow.webContents.on('dom-ready', () => {
    Promise.all([
      // Generated overrides for SoundCloud's "app.css"
      readFile(path.join(__dirname, 'dark-mode.app.css'), 'utf-8'),
      // Generated overrides for SoundCloud's inline styles
      readFile(path.join(__dirname, 'dark-mode.inline.css'), 'utf-8'),
      // Manual overrides
      readFile(path.join(__dirname, 'dark-mode.css'), 'utf-8')
    ])
      .then((cssFiles) => {
        mainWindow.webContents.insertCSS(
          `
          @media (prefers-color-scheme: dark) {
            ${cssFiles.join('\n')}
          }
          `,
          { cssOrigin: 'user' }
        )
      })
      .catch(console.error)
  })
}
