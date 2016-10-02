'use strict'

// Ignore setting onbeforeunload to prevent uncloseable windows
// See: https://github.com/electron/electron/issues/7424
Object.defineProperty(window, 'onbeforeunload', { set() {} })
