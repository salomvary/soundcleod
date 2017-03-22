'use strict'

const { TouchBar } = require('electron')
const { TouchBarButton, TouchBarLabel, TouchBarSpacer } = TouchBar

module.exports = function touchBarMenu(window, soundcloud) {

  const nextTrack = new TouchBarButton({
    icon: './app/res/next.png',
    click: () => {
      soundcloud.nextTrack()
    }
  })

  const previousTrack = new TouchBarButton({
    icon: './app/res/previous.png',
    click: () => {
      soundcloud.previousTrack()
    }
  })

  const playPause = new TouchBarButton({
    icon: './app/res/play.png',
    click: () => {
      soundcloud.playPause()
    }
  })

  const likeUnlike = new TouchBarButton({
    icon: './app/res/like.png',
    click: () => {
      soundcloud.likeUnlike()
    }
  })

  const trackInfo = new TouchBarLabel()

  soundcloud.on('play', ({ title, subtitle }) => {
    playPause.icon = './app/res/pause.png'
    // TODO fix this for playlists where subtitle is the playlist title
    trackInfo.label = title + ' by ' + subtitle
  })

  soundcloud.on('pause', () => {
    playPause.icon = './app/res/play.png'
    trackInfo.label = ''
  })

  const touchBar = new TouchBar([
    previousTrack,
    playPause,
    nextTrack,
    likeUnlike,
    new TouchBarSpacer({size: 'flexible'}),
    trackInfo,
    new TouchBarSpacer({size: 'flexible'})
  ])

  window.setTouchBar(touchBar)
}
