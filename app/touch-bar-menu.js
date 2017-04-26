'use strict'

const { TouchBar } = require('electron')

const { TouchBarButton, TouchBarLabel, TouchBarSpacer } = TouchBar
const MAX_TITLE_LENGTH = 39

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
      toggleLikeUnlikeIcon()
    }
  })

  function toggleLikeUnlikeIcon() {
    if(likeUnlike.icon == `${__dirname}/res/like.png`) {
      likeUnlike.icon = `${__dirname}/res/liked.png`
    } else {
      likeUnlike.icon = `${__dirname}/res/like.png`
    }
  }

  const repost = new TouchBarButton({
    icon: `${__dirname}/res/repost.png`,
    click: () => {
      soundcloud.repost()
    }
  })

  const trackInfo = new TouchBarLabel()

  soundcloud.on('play', ({ title, subtitle, trackMetadata }) => {
    playPause.icon = `${__dirname}/res/pause.png`
    trackInfo.label = formatTitle(title, subtitle)
    if(trackMetadata.isLiked) {
      likeUnlike.icon = `${__dirname}/res/liked.png`
    } else {
      likeUnlike.icon = `${__dirname}/res/like.png`
    }
  })

  soundcloud.on('pause', () => {
    playPause.icon = `${__dirname}/res/play.png`
  })

  const touchBar = new TouchBar([
    previousTrack,
    playPause,
    nextTrack,
    likeUnlike,
    repost,
    new TouchBarSpacer({ size: 'flexible' }),
    trackInfo,
    new TouchBarSpacer({ size: 'flexible' })
  ])

  window.setTouchBar(touchBar)
}

function formatTitle(title, subtitle) {
  const titleAndSubtitle = `${title} by ${subtitle}`
  if (titleAndSubtitle.length > MAX_TITLE_LENGTH)
    if (`${title} by X…`.length > MAX_TITLE_LENGTH)
      return truncate(title)
    else
      return truncate(titleAndSubtitle)
  return titleAndSubtitle
}

function truncate(text) {
  return text.substring(0, MAX_TITLE_LENGTH - 1) + '…'
}
