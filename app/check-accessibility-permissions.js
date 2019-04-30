'use strict'

const { dialog, systemPreferences } = require('electron')

/**
 * Using media keys on macOS requires the user's explicit permission
 * to "control the computer using accessibility features"
 *
 * See also:
 * https://github.com/salomvary/soundcleod/issues/174
 * https://github.com/electron/electron/issues/14837#issuecomment-433726878
 */
module.exports = function checkAccessibilityPermissions() {
  if (process.platform == 'darwin') {
    const isTrusted = systemPreferences.isTrustedAccessibilityClient(false)
    if (!isTrusted) {
      const clickedButton = dialog.showMessageBox(null, {
        type: 'warning',
        message: 'Turn on accessibility',
        detail:
          'To control playback in SoundCleod using media keys on your keyboard, ' +
          'select the SoundCleod checkbox in Security & Privacy > Accessibility.' +
          '\n\nYou will have to restart SoundCleod after enabling access.',
        defaultId: 1,
        cancelId: 0,
        buttons: ['Not Now', 'Turn On Accessibility']
      })
      if (clickedButton === 1) {
        // Calling isTrustedAccessibilityClient with prompt=true has the side effect
        // of showing the native dialog that either denies access or opens System
        // Preferences.
        // Note: the dialog does not block this call, the changes are only
        // effective after restarting SoundCleod.
        systemPreferences.isTrustedAccessibilityClient(true)
      }
    }
  }
}
