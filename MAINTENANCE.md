# SoundCleod Maintenance

This document is meant for SoundCleod maintainers.

# How to Make a Release

- `make release`
- Check if everything looks good
- `git push origin master --tags`
- `make update-website`
- Go to GitHub releases https://github.com/salomvary/soundcleod/releases
- Edit the draft release and copy the changes from CHANGELOG.md
- Publish the release
- Bump the version with `cd app && npm version prerelease --preid pre ---no-git-tag-version` and commit the changes

## Setting up the update server

- Go to https://github.com/GitbookIO/nuts
  - Click the "deploy to Heroku" button
  - Enter GitHub repo in `username/repo` format
  - Generate token here (leave all permissions off): https://github.com/settings/tokens
  - API username and password will be used for accessing Nuts' own internal API
- Verify if Nuts is working by going to https://app-name.herokuapp.com/
- Add a GitHub webhook here https://github.com/username/repo/settings/hooks/new
  - Set `GITHUB_SECRET` to a random string here: https://dashboard.heroku.com/apps/app-name/settings
  - Payload URL: https://app-name.herokuapp.com/refresh
  - Secret: enter the random string from above
  - Choose "Release published in a repository" event

## Redeploying the update server from CLI

- Clone the Nuts repo locally: https://github.com/GitbookIO/nuts
- Add the Heroku Git remote: `heroku git:remote --app soundcleod-updates`
- `git push heroku master`

## Working with self-signed code signing certificates on macOS

Start with opening Keychain Access.

Creating a certificate:

- Keychain Access menu > Certificate Assistant > Create a certificate...
- Enter your name (or whatever you want)
- Identity Type: Self Signed Root
- Certificate Type: Code Signing
- Continue, Done

Overriding the certificate trust levels:

- Open the certificate (double click)
- Expand "> Trust"
- Set "Code Signing" to "Always Trust"
- Close the certificate to save it
- Verify with `security find-identity -v -p codesigning`

Importing a certificate:

- File > Import items
- Select the certificate file
- Override trust levels as specified above

Exporting a macOS certificate for signing a Windows application:

- Find the certificate in Keychain Access
- Right click -> Export
- Choose .p12 format
- Add a strong password

## Setting up GitHub tokens on Travis CI and AppVeyor

This is required for automatically publishing releases to GitHub.

- Create a [new personal access token on GitHub](https://github.com/settings/tokens)
  - Only enable `public_repo` permission
- [Encrypt the token for AppVeyor here](https://ci.appveyor.com/tools/encrypt)
- Update `environment.GH_TOKEN.secure` with the token in `appveyor.yml`
- Update the token in `.travis.yml` with `travis encrypt --add env GH_TOKEN=<the token>` (install the Travis Gem first with `gem install travis`)
- Commit and push both `.travis.yml` and `appveyor.yml`

## Set up code signing certificates on Travis CI and AppVeyor

- Export the certificate as `codesign-certificate.p12`
- Encode file to base64 (macOS: `base64 -i codesign-certificate.p12 | pbcopy`, Linux: `base64 codesign-certificate.p12 > codesign-certificate.txt`).
- Set `CSC_LINK` and `CSC_KEY_PASSWORD` environment variables. The base64 encoded value goes into `CSC_LINK` without change.
  - [Travis CI Settings](https://travis-ci.org/salomvary/soundcleod/settings)
  - [AppVeyor Settings](https://ci.appveyor.com/project/salomvary/soundcleod/settings/environment)

## Building the website

    brew install rbenv
    rbenv install 2.3.3 # install latest ruby
    rbenv local 2.3.3
    ruby --version
    make run

See more in [GitHub Pages
documentation](https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/).
