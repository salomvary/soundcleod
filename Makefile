install-mac: pack
	rm -rf "/Applications/SoundCleod.app"
	cp -R "dist/mac/SoundCleod.app" /Applications

pack: dist/mac/SoundCleod.app

dist: build/icon.icns build/background.png build/icon.ico $(wildcard app/*)
	. .codesign && npm run dist

dist/mac/SoundCleod.app: build/icon.icns build/background.png $(wildcard app/*)
	. .codesign && npm run pack
	touch $@

build/icon.icns: build/icon.iconset
	iconutil -c icns -o $@ build/icon.iconset

build/icon.iconset: soundcleod.svg soundcleod-lo.svg
	mkdir -p $@
	node generate-images.js
	touch $@

build/background.png: background.svg
	mkdir -p build
	node generate-background.js
	touch $@

build/icon.ico: build/icon.iconset
	node_modules/.bin/to-ico \
		build/icon.iconset/icon_16x16.png \
		build/icon.iconset/icon_32x32.png \
		build/icon.iconset/icon_32x32@2x.png \
		build/icon.iconset/icon_128x128.png \
		build/icon.iconset/icon_256x256.png \
		> build/icon.ico

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
