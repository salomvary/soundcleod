NAME=$(shell node -e "console.log(require('./package.json').name)")
PRODUCT_NAME=$(shell node -e "console.log(require('./package.json').productName)")
VERSION=$(shell node -e "console.log(require('./package.json').version)")
ELECTRON_VERSION=$(shell npm --json list electron-prebuilt | node -e "console.log(JSON.parse(require('fs').readFileSync('/dev/stdin').toString()).dependencies['electron-prebuilt'].version)")
APP = dist/$(PRODUCT_NAME).app
DMG = dist/$(PRODUCT_NAME).dmg
ZIP = dist/$(PRODUCT_NAME)-mac.zip

dist: $(DMG) $(ZIP)

$(ZIP): package
	rm -f $(ZIP)
	cd dist && zip -r -y $(PRODUCT_NAME)-mac.zip $(PRODUCT_NAME).app

$(DMG): package
	rm -rf "$(APP)"
	cp -R "target/$(PRODUCT_NAME)-darwin-x64/$(PRODUCT_NAME).app" "$(APP)"
	cd dist && make

install-mac: package
	rm -rf "/Applications/$(PRODUCT_NAME).app"
	cp -r "target/$(PRODUCT_NAME)-darwin-x64/$(PRODUCT_NAME).app" /Applications

package: target/$(NAME).icns target/app/node_modules Credits.rtf
	. .codesign && \
	npm run electron-packager -- \
		target/app \
		"$(PRODUCT_NAME)" \
		--platform=darwin \
		--arch=x64 \
		--version=$(ELECTRON_VERSION) \
		--app-version=$(VERSION) \
		--icon target/$(NAME).icns \
		--app-copyright="$(shell head -n 1 LICENSE)" \
		--asar=true \
		--overwrite=true \
		--extend-info=Info.plist \
		--extra-resource=dsa_pub.pem \
		--extra-resource=Credits.rtf \
		--osx-sign.identity="$$CODE_SIGN_IDENTITY" \
		--out target

target/app/node_modules: target/app
	cd target/app && npm install --production
	touch $@

target/app: $(wildcard app/* package.json LICENSE)
	mkdir -p $@
	cp -r app package.json LICENSE $@
	touch $@

target/$(NAME).icns: target/$(NAME).iconset
	iconutil -c icns -o $@ target/$(NAME).iconset

target/$(NAME).iconset target/background.png: $(NAME).svg $(NAME)-lo.svg background.svg
	node generate-images.js
	touch $@

clean:
	rm -rf target
	make -C dist clean

mrproper:
	rm -rf target
	rm -rf node_modules

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
