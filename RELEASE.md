# How to Make a Release

## Manually

- Update CHANGELOG.md
- Update latest version in README.markdown
- Bump version in XCode (set both "version" and "build" to the same)
- `make clean; make dist`
- Update appcast.xml
  - `date +"%a, %d %b %G %T %z"`
  - `stat -f %z dist/SoundCleod.dmg`
  - `ruby sign_update.rb dist/SoundCleod.dmg dsa_priv.pem`
- Push to GitHub
- Update gh-pages on GitHub

## Scripted

- `make release`
- Check if everything looks good
- `git push`
- Update gh-pages on GitHub
