## 1.4.0 (August 31, 2018)

- Allow launching with a SoundCloud URL from the command line
- Security updates

## 1.3.4 (March 23, 2018)

- Fix broken history navigation shortcuts

## 1.3.3 (February 26, 2018)

- Fix reposting and liking tracks while searching #163 #165
- Fix Bluetooth headphone Play/Pause #159
- Fix "window is not defined" on network errors #149

## 1.3.2 (November 28, 2017)

- Fix notification spam when seeking or restarting play
- Adds a "repost" option to all of the menus
- Bring in latest security fixes from Electron (see https://electron.atom.io/releases/)

## 1.3.1 (October 17, 2017) (revoked release due to broken signatures)

- Fix notification spam when seeking or restarting play
- Adds a "repost" option to all of the menus
- Bring in latest security fixes from Electron (see https://electron.atom.io/releases/)

## 1.3.0 (April 20, 2017)

- Support Windows back/forward/home keys
- Add MacBook Touch Bar support

## 1.2.0 (March 14, 2017)

- Fix full screen closing/quitting on macOS
- Add like/unlike to the main and dock menus
- Show album art on desktop notification

## 1.1.9 (March 3, 2017)

- Fix black screen when closing fullscreen app

## 1.1.8 (January 17, 2017)

- Fix accidental back navigation when scrolling

## 1.1.7 (January 14, 2017)

- Add experimental swipe back/forward navigation
- Fix media key flakyness under some circumstances
- Fix crash on startup #130

## 1.1.6 (November 23, 2016)

- Release SoundCleod for Windows
- Yet another fix for Facebook login

## 1.1.5 (November 16, 2016)

- Allow hiding main window with Cmd+1
- Prevent quitting with Cmd+W on macOS

## 1.1.4 (November 14, 2016)

- Fix broken play/pause/prev/next menu items
- Prevent exception on right clicking certain elements
- Download updates from https://updates.soundcleod.com

## 1.1.3 (November 4, 2016)

- Fix Google login (again)
- Improve how window position is saved

## 1.1.2 (October 18, 2016)

- Log detailed errors for easier debugging

## 1.1.1 (October 18, 2016)

- Improve when the error screen is shown
- Show error code on the error screen
- Open share windows within SoundCleod (again)
- Fix Facebook login (again)

## 1.1.0 (October 7, 2016)

- Fix Facebook login
- Open external links in system browser
- Add standard actions to the context menu
- Remember window position and dimensions
- Tweak miniumm and default window dimensions
- Add Dock menu
- Add context menu back/forward navigation
- Add basic loading/error indicators
- Fix login/share windows width/height

## 1.0.0 (September 30, 2016)

SoundCleod was completely rewritten from scratch.

This new version uses the [Electron framework](http://electron.atom.io/) which
not only contains the latest cutting-edge Chrome version (hopefully solving all
playback problems) but also enables much easier development in the future.

This release fixes the following issues:

- Playback gets stuck frequently #107
- Sign in with Facebook does not work #109
- Sign in with Google does no work #53

The minimum supported macOS version changes from 10.7 (Lion) to 10.9 (Mavericks).

Some features were temporarily removed from SoundCleod to make this release
happen quickly. They will hopefully added back some time in the near future:

- The automatic updater no longer has any user interface, it downloads and
  installs new versions without prompting (on application restart)
- Dock menu controls were removed
- The "Edit URL" dialog (Cmd+L) was removed
- Microphone button controls were removed
- Space bar play/pause control only works if SoundCleod is in foreground

## 0.20 (June 17, 2016)

- Fix startup with blank screen (upgrade Sparkle to latest)
- Update the list of applications for media keys compatibility

## 0.19 (May 26, 2016)

- Fix broken media keys

## 0.18 (May 15, 2015)

- Added "History" and "Controls" menu
- Removed the "Install Flash" dialog
- Added DockMenu support for pause/play, previous and next

## 0.17 (December 19, 2014)

- detect and prompt when Flash Plugin is blocked by Safari

## 0.16 (December 7, 2014)

- Prompt for installing the plugin when no Flash for Safari is detected
- Show current URL in the "open location" dialog (Cmd+L)
- Fixed spacebar for keyboard navigation and play/pause when hidden

## 0.15 (November 13, 2014)

- Another attempt to fix scrolling issues with Yosemite

## 0.14 (November 5, 2014)

- Fix scrolling issues with Yosemite
- Removed swipe back-forward navigation
- Added microphone start/stop button support

## 0.13 (October 14, 2014)

- Fix broken media keys
- Fix broken "open SoundCloud url" dialog
- Support custom cleod:// url scheme

## 0.12 (November 8, 2013)

- Automatic updates yay!

## 0.11 (October 10, 2013)

- fixed closing window stops music in certain cases
- notifications support

## 0.10 (September 13, 2013)

- added reload menu item and Cmd+R shortcut
- added main window menu item and Cmd+1 shortcut

## 0.9.1 (August 1, 2013)

- distributed as .dmg package instead of Mac Installer
- compatible with OSX 10.7 Lion

## 0.9 (July 5, 2013)

- fixed ▶ media key
- support the new upload ui

## 0.8 (June 26, 2013)

- enabled Flash plugin which is required for playing certain sounds

## 0.7 (June 13, 2013)

- swipe for back/forward navigation
- fixed notifications and unread messages reappearing on every launch
- pause/start on spacebar even when the main window is not visible
- fixed restoring position and size on launch

## 0.6 (April 17, 2013)

- brought back the Edit menu, fixed lost copy&paste functionality
- one more shot on supporting pre Mt. Lion (should be confirmed)

## 0.5 (april 10, 2013)

- added basic full screen support
- close button hides main window without stopping play
- simplified menu bar
- introduced CHANGELOG :)
