'use strict'

const { app, Menu, MenuItem } = require('electron')

module.exports = function dockMenu(soundcloud) {
  const dockMenu = new Menu()
  dockMenu.append(new MenuItem({
    label: 'Play/Pause',
    click() {
      soundcloud.playPause()
    }
  }))
  dockMenu.append(new MenuItem({
    label: 'Like/Dislike',
    click() {
      soundcloud.likeDislike()
    }
  }))
  dockMenu.append(new MenuItem({
    label: 'Next',
    click() {
      soundcloud.nextTrack()
    }
  }))
  dockMenu.append(new MenuItem({
    label: 'Previous',
    click() {
      soundcloud.previousTrack()
    }
  }))

  app.dock.setMenu(dockMenu)
}
