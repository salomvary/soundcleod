'use strict'

const { execFile } = require('child_process')
const gulp = require('gulp')
const { name } = require('./app/package.json')
const rename = require('gulp-rename')
const svg2png = require('svg2png')
const through = require('through2')
const toIco = require('gulp-to-ico')
const Vinyl = require('vinyl')

/* eslint no-multi-spaces: off */

gulp.task(
  'iconset',
  gulp.parallel(
    () => generateIcon(`${name}-lo.svg`, 'icon_16x16.png', 16),
    () => generateIcon(`${name}-lo.svg`, 'icon_16x16@2x.png', 32),
    () => generateIcon(`${name}-lo.svg`, 'icon_32x32.png', 32),
    () => generateIcon(`${name}.svg`, 'icon_32x32@2x.png', 64),
    () => generateIcon(`${name}.svg`, 'icon_128x128.png', 128),
    () => generateIcon(`${name}.svg`, 'icon_128x128@2x.png', 256),
    () => generateIcon(`${name}.svg`, 'icon_256x256.png', 256),
    () => generateIcon(`${name}.svg`, 'icon_256x256@2x.png', 512),
    () => generateIcon(`${name}.svg`, 'icon_512x512.png', 512),
    () => generateIcon(`${name}.svg`, 'icon_512x512@2x.png', 1024)
  )
)

gulp.task('macos-icon', (cb) => {
  if (process.platform == 'darwin') {
    execFile(
      'iconutil',
      ['-c', 'icns', '-o', 'build/icon.icns', 'build/icon.iconset'],
      cb
    )
  } else {
    cb()
  }
})

gulp.task('windows-icon', () =>
  gulp
    .src([
      'build/icon.iconset/icon_16x16.png',
      'build/icon.iconset/icon_32x32.png',
      'build/icon.iconset/icon_32x32@2x.png',
      'build/icon.iconset/icon_128x128.png',
      'build/icon.iconset/icon_256x256.png'
    ])
    .pipe(toIco('icon.ico'))
    .pipe(gulp.dest('build'))
)

gulp.task(
  'icons',
  gulp.series('iconset', gulp.parallel('macos-icon', 'windows-icon'))
)

gulp.task('background', () =>
  gulp
    .src('background.svg')
    .pipe(svg2pngPlugin())
    .pipe(rename('background.png'))
    .pipe(gulp.dest('build'))
)

gulp.task('images', gulp.parallel('icons', 'background'))

function generateIcon(inputFile, outputFile, size) {
  return gulp
    .src(inputFile)
    .pipe(svg2pngPlugin({ width: size, height: size }))
    .pipe(rename(outputFile))
    .pipe(gulp.dest('build/icon.iconset'))
}

function svg2pngPlugin(options) {
  return through.obj((file, encoding, callback) => {
    svg2png(file.contents, options)
      .then((buffer) => {
        callback(
          null,
          new Vinyl({
            path: file.path,
            contents: buffer
          })
        )
      })
      .catch(callback)
  })
}
