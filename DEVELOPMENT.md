# SoundCleod Development

## Getting started

- Clone this repository locally.
- Install [Node.js](https://nodejs.org/) (SoundCleod is tested with the latest LTS version).
- Run `npm install` in the root folder of the project.

Run SoundCleod with the following command:

    npm start

SoundCleod comes with a small test suite:

    npm test # run all tests
    npm test -- test/options.js # run a single test file

The JavaScript code is verified with ESLint. It is strongly recommended to [install a plugin
for your editor](https://eslint.org/docs/user-guide/integrations#editors) or simply run `npm run eslint` from the command line. Some problems can automatically be fixed using `npm run eslint:fix`.

Consistent code formatting is enforced with Prettier. It is strongly recommended to [install a plugin
for your editor](https://prettier.io/docs/en/editors.html). To verify correct formatting run `npm run prettier` from the command line, to reformat files use `npm run prettier:fix`.

Now that you are all set start making changes and check out the [Electron documentation](https://electronjs.org/docs) for more!

## Packaging

Note: if you don't have a code signing certificate on macOS you should [create a self-signed one](MAINTENANCE.md#working-with-self-signed-code-signing-certificates-on-macos) before packaging SoundCleod.

The application can be packaged into a standalone executable with the npm `pack` script:

    npm run pack # package for the current platform
    npm run pack -- --win # package for a specific platform (--win or --mac)
    # The executables will be in the `dist` folder:
    dist/win-unpacked/SoundCleod.exe
    dist/mac/SoundCleod.app/Contents/MacOS/SoundCleod

Distributable installers can be built with the npm `dist` script:

    npm run dist # package for the current platform
    npm run dist -- --win # package for a specific platform (--win or --mac)
    # The installers will be in the `dist` folder:
    dist/squirrel-windows/SoundCleod Setup 1.4.0.exe
    dist/SoundCleod-1.4.0.dmg

## Debugging with Chromium Web Developer Tools

Start SoundCleod with `npm start` or the installed application with `--developer-tools`:

    /Applications/SoundCleod.app/Contents/MacOS/SoundCleod --developer-tools

Use Cmd+Option+I to toggle Developer Tools or use View > Toggle Developer Tools from the menu.

## Tricks and tips

Starting SoundCleod with arguments on Windows (installed location)

    %USERPROFILE%\AppData\Local\soundcleod\Update.exe --processStart "SoundCleod.exe" --process-start-args "arg1 arg2"

Override what version to build:

    npm run dist -- --em.version=1.1.7-pre.1

Debugging packaging and code signing:

    DEBUG=electron-builder,electron-osx-sign npm run pack

Remove persisted data on macOS:

    rm -rf ~/Library/Application\ Support/SoundCleod\ development/
    rm -rf ~/Library/Application\ Support/SoundCleod/
