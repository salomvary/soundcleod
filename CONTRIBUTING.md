# Contributing to SoundCleod

First of all, thank you for taking the time to contribute!

The following is a set of guidelines for contributing to SoundCleod. These are
not rules carved into stone, feel free to bend them when necessary;)

If your are new to developing SoundCleod head to the [development
docs](DEVELOPMENT.md).

## Submitting bug reports

Please **do not report issues with soundcloud.com** here. If you found a bug or have some other problem using SoundCloud's website or mobile apps please [contact
SoundCloud through one of their support channels directly](https://soundcloud.com/pages/contact).

Besides a clear explanation of what problem you are facing please provide the
following details:

- What SoundCleod version you are using
- What operating system you are using (with version)
- What are the steps to reproduce the issue
- Screenshots when applicable

## Requesting or adding new features

SoundCleod is meant to be a _lightweight_ desktop application for
soundcloud.com. Although there are thousands of ways to extend the
functionality of both the application and the website please be very
considerate when coming up with new ideas.

These are the new features that are welcome in SoundCleod:

- Things users can do when using soundcloud.com with traditional web browsers
  but not with SoundCleod
- Improving desktop integration of SoundCleod as a media player

There are a few things that will not be accepted:

- Adding features to soundcloud.com or removing existing ones
- Removing ads from soundcloud.com (consider buying SoundCloud Go subscription to remove ads)
- Anything that makes copyright infringement possible or easy
- Anything that makes spamming possible or easy
- Changes introducing security risk

## Submitting pull requests

There are a few conventions to follow:

- Indent with two spaces
- No semicolons in JavaScript
- Change one thing only in a pull request
- Make sure there are no failing tests, code quality and styling errors (`npm run verify` must pass)
- Keep commit messages short
- Use the present tense in commit messages ("Add feature" not "Added feature")
- Use the imperative mood in commit messages ("Move cursor to..." not "Moves cursor to...")
