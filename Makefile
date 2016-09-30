install-mac: pack
	rm -rf "/Applications/SoundCleod.app"
	cp -R "dist/mac/SoundCleod.app" /Applications

pack: dist/mac/SoundCleod.app

dist: build/icon.icns build/background.png $(wildcard app/*)
	npm run dist

dist/mac/SoundCleod.app: build/icon.icns build/background.png $(wildcard app/*)
	npm run pack
	touch $@

build/icon.icns: build/icon.iconset
	iconutil -c icns -o $@ build/icon.iconset

build/icon.iconset: soundcleod.svg soundcleod-lo.svg
	node generate-images.js
	touch $@

build/background.png: background.svg
	node generate-background.js
	touch $@

clean:
	rm -rf build dist

mrproper: clean
	rm -rf node_modules app/node_modules

increment_version:
	./release.sh increment_version

history:
	./release.sh history

release: clean increment_version dist history
	git add README.markdown CHANGELOG.md package.json
	git commit -m "v$$(./release.sh print_version)"
	git tag -m "v$$(./release.sh print_version)" "v$$(./release.sh print_version)"

update-website:
	git checkout gh-pages
	make update-readme update-and-push
	git checkout master

.PHONY: dist
