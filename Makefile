.DEFAULT_GOAL := build
DIST_FOLDER = ./dist

clean:
	@echo "Cleaning up…"
	xcodebuild clean
	rm -rf ./dist/

prepare:
	@echo "Installing CocoaPods dependencies for IndentHub SDK build…"
	pod install

build-binaries-for-device:
	@echo "Building binaries for devices…"
	xcodebuild archive \
		-workspace IdentHubSDK.xcworkspace \
		-scheme IdentHubSDK \
		-destination "generic/platform=iOS" \
		-archivePath ${DIST_FOLDER}/IdentHubSDK \
		SKIP_INSTALL=NO \
		INSTALL_PATH=/Library/Frameworks \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES

build-binaries-for-simulator:
	@echo "Building binaries for simulator…"
	xcodebuild archive \
		-workspace IdentHubSDK.xcworkspace \
		-scheme IdentHubSDK \
		-destination "generic/platform=iOS Simulator" \
		-archivePath ${DIST_FOLDER}/IdentHubSDK-Simulator \
		SKIP_INSTALL=NO \
		INSTALL_PATH=/Library/Frameworks \
		BUILD_LIBRARY_FOR_DISTRIBUTION=YES

build-binaries: build-binaries-for-device build-binaries-for-simulator

build-identhub-xcframework:
	@echo "Building IdentHubSDK xcframework…"
	rm -rf ${DIST_FOLDER}/IdentHubSDK.xcframework
	xcodebuild -create-xcframework \
		-framework ${DIST_FOLDER}/IdentHubSDK.xcarchive/Products/Library/Frameworks/IdentHubSDK.framework \
		-framework ${DIST_FOLDER}/IdentHubSDK-Simulator.xcarchive/Products/Library/Frameworks/IdentHubSDK.framework \
		-output ${DIST_FOLDER}/IdentHubSDK.xcframework

build: build-binaries build-identhub-xcframework

build-dependencies:
	@echo "Building dependency binaries with Carthage…"
	carthage update --use-xcframeworks --platform ios
