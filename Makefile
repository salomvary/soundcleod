APP = dist/SoundCleod.app
DMG = dist/SoundCleod.dmg

build: $(APP)

dist: $(DMG)

$(DMG): build
	cd dist && make

$(APP):
	. .codesign && xcodebuild -project SoundCleod.xcodeproj -configuration Archive -scheme SoundCleod CODE_SIGN_IDENTITY="$$CODE_SIGN_IDENTITY" CONFIGURATION_BUILD_DIR=dist DWARF_DSYM_FOLDER_PATH=build/Release

run: build
	open $(APP)

.PHONY: clean
clean: dist-clean
	-rm -rf $(APP)
	xcodebuild -project SoundCleod.xcodeproj -configuration Archive -scheme SoundCleod clean CONFIGURATION_BUILD_DIR=dist DWARF_DSYM_FOLDER_PATH=build/Release

.PHONY: dist-clean
dist-clean:
	cd dist && make clean
