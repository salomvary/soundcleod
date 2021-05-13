'use strict'

const { TouchBar, nativeImage } = require('electron')

const { TouchBarButton, TouchBarLabel, TouchBarSpacer, TouchBarScrubber } = TouchBar

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
    items:[{
      label: ''
    }]
  })

  soundcloud.on('play-new-track', ({ title, subtitle, artworkURL }) => {
    titleScrubber.items = [{
      label: title
    }]
    https.get(artworkURL, res => {
    let data = [];
      res.on('data', chunk => {
        data.push(chunk);
      });
      res.on('end', () => {
        var x = nativeImage.createFromBuffer(Buffer.concat(data)).resize({height:30, width:30})
        titleScrubber.items = [{
          icon: x
        }, {
          label: title
        }]
      });
    }).on('error', err => {
      titleScrubber.items = [{
        label: title
      }]
    });
  })

  soundcloud.on('play', ({ title, subtitle }) => {
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