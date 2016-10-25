'use strict'

const { app } = require('electron')

module.exports = function errorHandlers(window) {
  window.webContents.on('did-fail-load', (event, errorCode, description, url, isMainFrame) => {
    const redirectErrorCode = -3
    if (isMainFrame && errorCode != redirectErrorCode) {
      window.loadURL(`file://${__dirname}/error.html?error=${encodeURIComponent(description)}`)
      console.error(`Failed to load '${url}' with ${description}`)
    }
  })

  app.on('certificate-error', (event, webContents, url, error, certificate) => {
    console.error(`Certificate error on '${url}': ${error}`)
    console.error(`Certificate data: ${formatCertificate(certificate)}`)
  })

  function formatCertificate({issuerName, subjectName, serialNumber, validStart, validExpiry, fingerprint}) {
    return JSON.stringify({
      issuerName,
      subjectName,
      serialNumber,
      validStart: new Date(validStart * 1000).toUTCString(),
      validExpiry: new Date(validExpiry * 1000).toUTCString(),
      fingerprint
    })
  }
}
