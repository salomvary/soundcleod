// Adopted from https://github.com/MarshallOfSound/Google-Play-Music-Desktop-Player-UNOFFICIAL-/blob/master/src/renderer/windows/GPMWebView/interface/customNavigation/mouseButtonNavigation.js
// Alternatives to consider:
// https://github.com/wozaki/twitter-js-apps/blob/9bc00eafd575fd180dc7a450e1b1daf425e67b80/redux/src/main/renderer/registries/electron/swipeNavigatorImpl.js
// TODO publish this as a standalone module

'use strict'

const { remote } = require('electron')

module.exports.register = function register() {
  remote.getCurrentWindow()
    .on('scroll-touch-begin', onScrollBegin)
    .on('scroll-touch-end', onScrollEnd)
    .on('swipe', onSwipe)

  window.addEventListener('mousewheel', onMouseWheel, {passive: true})
  window.addEventListener('beforeunload', remove)
}

const remove = module.exports.remove = function remove() {
  remote.getCurrentWindow()
    .removeListener('scroll-touch-begin', onScrollBegin)
    .removeListener('scroll-touch-end', onScrollEnd)
    .removeListener('swipe', onSwipe)

  window.removeEventListener('mousewheel', onMouseWheel)
  window.removeEventListener('beforeunload', remove)
}

let scrolling = false
let scrollingShouldNav = 0
const NAV_VELOCITY = 30

function onSwipe(e, direction) {
  if (direction === 'left')
    remote.getCurrentWebContents.goBack()
  else if (direction === 'right')
    remote.getCurrentWebContents().goForward()
}

function onMouseWheel(e) {
  if (e.deltaX > NAV_VELOCITY && scrolling)
    scrollingShouldNav = 1
  else if (e.deltaX < -1 * NAV_VELOCITY && scrolling)
    scrollingShouldNav = -1
}

function onScrollBegin() {
  scrolling = true
}

function onScrollEnd() {
  scrolling = false
  // TODO figure out how to avoid navigating if the window contents or
  // a scrollable element within the window was actually scrolled
  if (scrollingShouldNav) {
    if (scrollingShouldNav > 0)
      remote.getCurrentWebContents().goForward()
    else
      remote.getCurrentWebContents().goBack()
    scrollingShouldNav = 0
  }
}

