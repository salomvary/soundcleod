/* eslint  import/no-extraneous-dependencies: off */

'use strict'

const fs = require('fs')
const svg2png = require('svg2png')

function generate(input, out, ratio) {
  const options = {
    width: (256 * ratio),
    height: (256 * ratio)
  }
  fs.writeFileSync(out, svg2png.sync(fs.readFileSync(input), options))
  console.log(out)
}

generate('soundcleod-lo.svg', 'build/icon.iconset/icon_16x16.png', 1 / 16)
generate('soundcleod-lo.svg', 'build/icon.iconset/icon_16x16@2x.png', 1 / 8)
generate('soundcleod-lo.svg', 'build/icon.iconset/icon_32x32.png', 1 / 8)
generate('soundcleod.svg', 'build/icon.iconset/icon_32x32@2x.png', 1 / 4)
generate('soundcleod.svg', 'build/icon.iconset/icon_128x128.png', 1 / 2)
generate('soundcleod.svg', 'build/icon.iconset/icon_128x128@2x.png', 1)
generate('soundcleod.svg', 'build/icon.iconset/icon_256x256.png', 1)
generate('soundcleod.svg', 'build/icon.iconset/icon_256x256@2x.png', 2)
generate('soundcleod.svg', 'build/icon.iconset/icon_512x512.png', 2)
generate('soundcleod.svg', 'build/icon.iconset/icon_512x512@2x.png', 4)
