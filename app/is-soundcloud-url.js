'use strict'

const url = require('url')

module.exports = function isSoundcloudUrl(candidate) {
  if (candidate) {
    if (validate(candidate)) {
      return true
    }
    console.warn(`Ignored invalid SoundCloud URL argument ${candidate}`)
  }
}

function validate(candidate) {
  try {
    const { protocol, hostname } = url.parse(candidate.toLowerCase())
    return (
      (protocol === 'http:' || protocol === 'https:') &&
      hostname === 'soundcloud.com'
    )
  } catch (e) {
    return false
  }
}
