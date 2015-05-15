#!/bin/sh

info_plist=SoundCleod/SoundCleod-Info.plist

# Reads the project version from Info.plist
print_version() {
	/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$info_plist"
}

# Increments the project version in Info.plist
increment_plist_version() {
	print_version | increment_version | set_version
}

increment_version() {
	awk -F . '{OFS="."; ++$2; print}'
}

set_version() {
	new_version=$(cat)
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $new_version" "$info_plist"
	/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $new_version" "$info_plist"
}

# Updates the current version in README.markdown from Info.plist
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

# Reads history from stdin (one entry per line) and appennds it to appcast.xml
update_appcast() {
	format_changelog_html | appcast_item | append_appcast_item
}

format_changelog_html() {
	while read line; do
		echo "<li>$line</li>"
	done
}

appcast_item() {
	history=$(cat)
	version=$(print_version)
	date=$(date +"%a, %d %b %G %T %z")
	length=$(stat -f %z dist/SoundCleod.dmg)
	signature=$(ruby sign_update.rb dist/SoundCleod.dmg dsa_priv.pem)

	item=$(m4 -DCHANGELOG="$history" -DVERSION="$version" -DDATE="$date" -DLENGTH="$length" -DSIGNATURE="$signature" appcast-item.xml)
	echo "$item"
}

# Poor man's xml manipulator to add an <item> to appcast.xml
append_appcast_item() {
	item=$(sed -e 's/\//\\\//g' | sed -e 's/$/\\/')
	sed -i '' -e "s/	<\\/channel>/$item
	<\\/channel>/" appcast.xml
}

print_usage() {
  echo "Usage: $(basename "$0") increment_version Bump app version before build"
  echo "       $(basename "$0") print_version     Print app version"
  echo "       $(basename "$0") history           Update README, CHANGELOG and appcast.xml"
}

main() {
	case "$1" in
		print_version)
			print_version
			;;
		increment_version)
			increment_plist_version
			;;
		history)
			update_readme_version
			changes=$(read_changes)
			echo "$changes" | update_appcast
			echo "$changes" | update_changelog
			;;
		*)
			print_usage
			exit 1
			;;
	esac
}

main "$@"
