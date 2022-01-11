'use strict'

const {TouchBar, nativeImage, shell} = require('electron')

const {TouchBarScrubber, TouchBarSegmentedControl} = TouchBar

const https = require('https')

module.exports = function touchBarMenu(window, soundcloud) {
  const playPause = {
    icon: `${__dirname}/res/play.png`
  }
  /*  const likeUnlike = new TouchBarButton({
      icon: `${__dirname}/res/like.png`,
      click: () => {
        soundcloud.likeUnlike()
      }
    }) */

  let openTrackLink

  const titleScrubber = new TouchBarScrubber({
    continuous: false,
    items: [
      {
        label: 'Soundcleod'
      }
    ],
    highlight: highlightedIndex => {
      if (openTrackLink !== undefined && highlightedIndex === 1)
        shell.openExternal(openTrackLink)
    }
  })

  soundcloud.on('play-new-track', ({title, subtitle, artworkURL, trackURL}) => {
    let displayTitle = `${title} by ${subtitle}`
    displayTitle = displayTitle.padEnd(displayTitle.length * 1.3, ' ')
    let loadingFrame = 0

    openTrackLink = undefined

    const intervalId = setInterval(() => {
      loadingFrame = loadingFrame > 10 ? 0 : loadingFrame + 1
      titleScrubber.items = [
        {
          label: ''
        },
        {
          icon: `${__dirname}/res/ajax${loadingFrame}.png`
        },
        {
          label: displayTitle
        }
      ]
    }, 80)
    https.get(artworkURL, (res) => {
      const data = []
      res.on('data', (chunk) => {
        data.push(chunk)
      })
      res.on('end', () => {
        clearInterval(intervalId)
        titleScrubber.items = [
          {
            label: ''
          },
          {
            icon: nativeImage
              .createFromBuffer(Buffer.concat(data))
              .resize({height: 30, width: 30})
          },
          {
            label: displayTitle
          }
        ]
        openTrackLink = trackURL
      })
      res.on('error', () => {
        clearInterval(intervalId)
        titleScrubber.items = [
          {
            label: ''
          },
          {
            label: displayTitle
          }
        ]
      })
    })
  })

  soundcloud.on('play', () => {
    playPause.icon = `${__dirname}/res/pause.png`
    resetTouchBar()
  })

  soundcloud.on('pause', () => {
    playPause.icon = `${__dirname}/res/play.png`
    resetTouchBar()
  })

  const touchBarSegmentedControl = new TouchBarSegmentedControl({
    segmentStyle: "rounded",
    mode: "buttons",
    change: selectedIndex => {
      if (selectedIndex === 0)
        soundcloud.previousTrack()
      else if (selectedIndex === 1)
        soundcloud.playPause()
      else if (selectedIndex === 2)
        soundcloud.nextTrack()
      else if (selectedIndex === 3)
        soundcloud.repost()
    }
  })

  resetTouchBar()

  const touchBar = new TouchBar({
    items: [
      touchBarSegmentedControl,
      titleScrubber
    ]
  })
  window.setTouchBar(touchBar)

  function resetTouchBar() {
    touchBarSegmentedControl.segments = [
      {icon: `${__dirname}/res/previous.png`},
      playPause,
      {icon: `${__dirname}/res/next.png`},
      {icon: `${__dirname}/res/repost.png`}
    ]
  }
}
