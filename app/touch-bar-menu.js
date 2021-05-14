'use strict'

const { TouchBar, nativeImage } = require('electron')

const { TouchBarButton, TouchBarScrubber } = TouchBar

const https = require('https');

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

  const repost = new TouchBarButton({
    icon: `${__dirname}/res/repost.png`,
    click: () => {
      soundcloud.repost()
    }
  })

  const titleScrubber = new TouchBarScrubber({
    continuous: false,
    items:[{
      label: ''
    }]
  })

  soundcloud.on('play-new-track', ({ title, artworkURL }) => {
    titleScrubber.items = [{
      label: title
    }]
    https.get(artworkURL, res => {
      const data = [];
      res.on('data', chunk => {
        data.push(chunk);
      });
      res.on('end', () => {
        titleScrubber.items = [{
          icon: nativeImage.createFromBuffer(Buffer.concat(data)).resize({height:30, width:30})
        }, {
          label: title
        }]
      });
    }).on('error', () => {
      titleScrubber.items = [{
        label: title
      }]
    });
  })

  soundcloud.on('play', () => {
    playPause.icon = `${__dirname}/res/pause.png`
  })

  soundcloud.on('pause', () => {
    playPause.icon = `${__dirname}/res/play.png`
  })

  const touchBar = new TouchBar({
      items:[
        previousTrack,
        playPause,
        nextTrack,
        likeUnlike,
        repost,
        titleScrubber
      ]
    })

  window.setTouchBar(touchBar)
}