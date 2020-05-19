#!/bin/sh

print_version() {
  node -e "console.log(require('./app/package.json').version)"
}

# Increment version in package.json
increment_version() {
  cd app && npm version --git-tag-version false patch && cd ..
}

# Updates the current version in README.markdown
update_readme_version() {
	version=$(print_version)
	date=$(date '+%B %e, %Y')
	sed -i '' -E -e\
	 	"s/Current version is [^[:space:]]+ \([^(]+\)/Current version is $version ($date)/"\
		README.markdown
}

# Read changes from git log and open it in an editor
read_changes() {
	tmp_history=$(mktemp -t soundcleod-history)
	git log\
	 	--first-parent --pretty=format:"%s"\
	 	"$(git describe --abbrev=0 --tags)..master"\
	 	> "$tmp_history"
	$EDITOR "$tmp_history" < /dev/tty > /dev/tty || exit $?
	cat "$tmp_history"
}


# Reads history from stdin (one entry per line) and prepends it to CHANGELOG.md
update_changelog() {
	format_changelog_markdown | write_changelog
}

format_changelog_markdown() {
	while read line; do
		echo "- $line"
	done
}

write_changelog() {
	history=$(cat)
	tmp_changelog=$(mktemp -t soundleod-changelog)
	version=$(print_version)
	date=$(date '+%B %e, %Y')
	{
		echo "## $version ($date)"
		echo "$history"
		echo
		cat CHANGELOG.md
	}	> "$tmp_changelog"
	mv "$tmp_changelog" CHANGELOG.md
}

print_usage() {
  echo "Usage: $(basename "$0") increment_version     Bump app version before build"
  echo "       $(basename "$0") print_version         Print app version"
  echo "       $(basename "$0") update_readme_version Update version information in the README"
  echo "       $(basename "$0") history               Update README, CHANGELOG and appcast.xml"
}

main() {
	case "$1" in
		print_version)
			print_version
			;;
		increment_version)
			increment_version
			;;
		update_readme_version)
			update_readme_version
			;;
		history)
			update_readme_version
			changes=$(read_changes)
			echo "$changes" | update_changelog
			;;
		*)
			print_usage
			exit 1
			;;
	esac
}

main "$@"
