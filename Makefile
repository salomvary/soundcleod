install-mac: pack
	rm -rf "/Applications/SoundCleod.app"
	cp -R "dist/mac/SoundCleod.app" /Applications

pack:
	. ./.codesign && npm run pack

dist-mac:
	. ./.codesign && npm run dist -- --mac

dist-win:
	. ./.codesign && npm run dist -- --win

release-mac:
	. ./.codesign && npm run release -- --mac

release-win:
	. ./.codesign && npm run release -- --win

docker-dist-win:
	docker run --rm \
		-e DEBUG \
		-v "$(CURDIR):/project" \
		-v ~/.electron:/root/.electron \
		electronuserland/electron-builder:wine \
		make dist-win

docker-release-win:
	docker run --rm \
		-e DEBUG \
		-v "$(CURDIR):/project" \
		-v ~/.electron:/root/.electron \
		electronuserland/electron-builder:wine \
		make release-win

clean:
	rm -rf build dist

mrproper: clean
	rm -rf node_modules app/node_modules

increment_version:
	./release.sh increment_version

history:
	./release.sh history

release: clean increment_version release-mac docker-release-win history
	git add README.markdown CHANGELOG.md app/package.json app/npm-shrinkwrap.json
	git commit -m "v$$(./release.sh print_version)"
	git tag -m "v$$(./release.sh print_version)" "v$$(./release.sh print_version)"

update-website:
	git checkout gh-pages
	make update-readme update-and-push
	git checkout master

.PHONY: dist
