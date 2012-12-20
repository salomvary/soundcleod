var svg2png = require('svg2png');

svg2png('soundcleod-lo.svg', 'soundcleod.iconset/icon_16x16.png', 1/16, function(e) {});
svg2png('soundcleod-lo.svg', 'soundcleod.iconset/icon_16x16@2x.png', 1/8, function(e) {});
svg2png('soundcleod-lo.svg', 'soundcleod.iconset/icon_32x32.png', 1/8, function(e) {});
svg2png('soundcleod.svg', 'soundcleod.iconset/icon_32x32@2x.png', 1/4, function(e) {});
svg2png('soundcleod.svg', 'soundcleod.iconset/icon_128x128.png', 1/2, function(e) {});
svg2png('soundcleod.svg', 'soundcleod.iconset/icon_128x128@2x.png', 1, function(e) {});
svg2png('soundcleod.svg', 'soundcleod.iconset/icon_256x256.png', 1, function(e) {});
svg2png('soundcleod.svg', 'soundcleod.iconset/icon_256x256@2x.png', 2, function(e) {});
svg2png('soundcleod.svg', 'soundcleod.iconset/icon_512x512.png', 2, function(e) {});
svg2png('soundcleod.svg', 'soundcleod.iconset/icon_512x512@2x.png', 4, function(e) {});
