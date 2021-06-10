'use strict'
const discordClient = require('discord-rich-presence')('852328413359767562'); 

let connected = false;
discordClient.on('error', err => {
  console.log(`Error: ${err}`);
});
discordClient.on("connected", () => {
  connected = true;
});

module.exports = function discord(window, soundcloud) {
  soundcloud.on('play-new-track', ({ title, subtitle, artworkURL }) => {
    if (!connected)
      return;
    let displayTitle = `${title} by ${subtitle}`
    discordClient.updatePresence({
      state: displayTitle,
      details: displayTitle,
      startTimestamp: Date.now(),
      largeImageKey: 'soundcleod',
      smallImageKey: 'soundcleod',
      instance: false
    });
  });
};
