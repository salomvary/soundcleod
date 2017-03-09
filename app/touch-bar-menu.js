'use strict'

const {app, BrowserWindow, TouchBar} = require('electron')
const {TouchBarButton, TouchBarLabel, TouchBarSpacer} = TouchBar

module.exports = function touchBarMenu(window, soundcloud) {

  const nextTrack = new TouchBarButton({
    label: '⏭',
    click: () => {
      soundcloud.nextTrack()
    }
  })

  const previousTrack = new TouchBarButton({
    label: '⏮',
    click: () => {
      soundcloud.previousTrack()
    }
  })

  const playPause = new TouchBarButton({
    label: '⏯',
    click: () => {
      soundcloud.playPause()
    }
  })

  const likeDislike = new TouchBarButton({
    label: '❤️'
  })

  const trackInfo = new TouchBarLabel()

  soundcloud.on('play', (title, subtitle) => {
    trackInfo.label = title + ' by ' + subtitle
  })

  const touchBar = new TouchBar([
    previousTrack,
    playPause,
    nextTrack,
    likeDislike,
    new TouchBarSpacer({size: 'flexible'}),
    trackInfo,
    new TouchBarSpacer({size: 'flexible'})
  ])
  
  window.setTouchBar(touchBar)
}
