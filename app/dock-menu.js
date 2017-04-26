'use strict'

const { app, Menu } = require('electron')

module.exports = function dockMenu(soundcloud) {
  const menu = Menu.buildFromTemplate([
    {
      label: 'Play/Pause',
      click() {
        soundcloud.playPause()
      }
    },
    {
      label: 'Like',
      click() {
        soundcloud.likeUnlike()
      }
    },
    {
      label: 'Repost',
      click() {
        soundcloud.repost()
      }
    },
    {
      label: 'Next',
      click() {
        soundcloud.nextTrack()
      }
    },
    {
      label: 'Previous',
      click() {
        soundcloud.previousTrack()
      }
    }
  ])

  app.dock.setMenu(menu)
}
