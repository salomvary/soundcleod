'use strict'

const { TouchBar } = require('electron')

const { TouchBarButton, TouchBarLabel, TouchBarSpacer } = TouchBar
const MAX_TITLE_LENGTH = 38

module.exports = function touchBarMenu(window, soundcloud) {
  const nextTrack = new TouchBarButton({
    icon: `${__dirname}/res/next.png`,
    click: () => {
      soundcloud.nextTrack()
    }
  })

  const previousTrack = new TouchBarButton({
    icon: `${__dirname}/res/previous.png`,
    click: () => {
      soundcloud.previousTrack()
    }
  })

  const playPause = new TouchBarButton({
    icon: `${__dirname}/res/play.png`,
    click: () => {
      soundcloud.playPause()
    }
  })

  const likeUnlike = new TouchBarButton({
    icon: `${__dirname}/res/like.png`,
    click: () => {
      soundcloud.likeUnlike()
    }
  })

  const trackInfo = new TouchBarLabel()

  soundcloud.on('play', ({ title, subtitle }) => {
    playPause.icon = `${__dirname}/res/pause.png`
    trackInfo.label = formatTitle(title, subtitle)
  })

  soundcloud.on('pause', () => {
    playPause.icon = `${__dirname}/res/play.png`
  })

  const touchBar = new TouchBar([
    previousTrack,
    playPause,
    nextTrack,
    likeUnlike,
    new TouchBarSpacer({ size: 'flexible' }),
    trackInfo,
    new TouchBarSpacer({ size: 'flexible' })
  ])

  window.setTouchBar(touchBar)
}

function formatTitle(title, subtitle) {
  const titleAndSubtitle = `${title} by ${subtitle}`
  if (titleAndSubtitle.length > MAX_TITLE_LENGTH) {
    if (`${title} by X…`.length > MAX_TITLE_LENGTH) {
      return truncate(title)
    }
    return truncate(titleAndSubtitle)
  }
  return titleAndSubtitle
}

function truncate(text) {
  return text.substring(0, MAX_TITLE_LENGTH - 1) + '…'
}
