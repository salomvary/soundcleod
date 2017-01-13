'use strict'

const fs = require('fs')
const svg2png = require('svg2png')

function generate(input, out) {
  fs.writeFileSync(out, svg2png.sync(fs.readFileSync(input)))
  console.log(out)
}

generate('background.svg', 'build/background.png')

