'use strict'

const { app } = require('electron')

module.exports = function errorHandlers(window) {
  window.webContents.on('did-fail-load', onDidFailLoad)
  app.on('certificate-error', onCertificateError)
}

function onCertificateError(event, webContents, url, error, certificate) {
  console.error(`Certificate error on '${url}': ${error}`)
  console.error(`Certificate data: ${formatCertificate(certificate)}`)
}

function formatCertificate({
  issuerName,
  subjectName,
  serialNumber,
  validStart,
  validExpiry,
  fingerprint
}) {
  return JSON.stringify({
    issuerName,
    subjectName,
    serialNumber,
    validStart: new Date(validStart * 1000).toUTCString(),
    validExpiry: new Date(validExpiry * 1000).toUTCString(),
    fingerprint
  })
}

function onDidFailLoad(event, errorCode, description, url, isMainFrame) {
  const redirectErrorCode = -3
  if (isMainFrame && errorCode != redirectErrorCode) {
    this.loadURL(
      `file://${__dirname}/error.html?error=${encodeURIComponent(
        description
      )}&appName=${app.name}`
    )
    console.error(`Failed to load '${url}' with ${description}`)
  }
}
