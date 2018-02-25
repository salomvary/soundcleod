# How to Make a Release

- `make release`
- Check if everything looks good
- `git push origin master --tags`
- `make update-website`
- Go to GitHub releases https://github.com/salomvary/soundcleod/releases
- Edit the draft release and copy the changes from CHANGELOG.md
- Publish the release
- Bump the version with `cd app && npm version prerelease ---no-git-tag-version` and commit the changes
