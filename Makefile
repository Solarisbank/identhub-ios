.DEFAULT_GOAL := build
DIST_FOLDER = ./dist
BANK_FOLDER = ./dist/bank
QES_FOLDER = ./dist/qes
FOURTHLINE_FOLDER = ./dist/fourthline

clean:
	@echo "Cleaning up…"
	xcodebuild clean
	rm -rf ./dist/
	rm -rf ./Cartfile.resolved
	rm -rf ./Carthage

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
		
build-identhub-core-xcframework:
	@echo "Building IdentHubSDKCore xcframework…"
	rm -rf ${DIST_FOLDER}/IdentHubSDKCore.xcframework
	xcodebuild -create-xcframework \
		-framework ${DIST_FOLDER}/IdentHubSDK.xcarchive/Products/Library/Frameworks/IdentHubSDKCore.framework \
		-framework ${DIST_FOLDER}/IdentHubSDK-Simulator.xcarchive/Products/Library/Frameworks/IdentHubSDKCore.framework \
		-output ${DIST_FOLDER}/IdentHubSDKCore.xcframework

build-identhub-bank-xcframework:
	@echo "Building IdentHubSDKBank xcframework…"
	rm -rf ${BANK_FOLDER}/IdentHubSDKBank.xcframework
	xcodebuild -create-xcframework \
		-framework ${DIST_FOLDER}/IdentHubSDK.xcarchive/Products/Library/Frameworks/IdentHubSDKBank.framework \
		-framework ${DIST_FOLDER}/IdentHubSDK-Simulator.xcarchive/Products/Library/Frameworks/IdentHubSDKBank.framework \
		-output ${BANK_FOLDER}/IdentHubSDKBank.xcframework

build-identhub-fourthline-xcframework:
	@echo "Building IdentHubSDKFourthline xcframework…"
	rm -rf ${FOURTHLINE_FOLDER}/IdentHubSDKFourthline.xcframework
	xcodebuild -create-xcframework \
		-framework ${DIST_FOLDER}/IdentHubSDK.xcarchive/Products/Library/Frameworks/IdentHubSDKFourthline.framework \
		-framework ${DIST_FOLDER}/IdentHubSDK-Simulator.xcarchive/Products/Library/Frameworks/IdentHubSDKFourthline.framework \
		-output ${FOURTHLINE_FOLDER}/IdentHubSDKFourthline.xcframework

build-identhub-qes-xcframework:
	@echo "Building IdentHubSDKQES xcframework…"
	rm -rf ${QES_FOLDER}/IdentHubSDKQES.xcframework
	xcodebuild -create-xcframework \
		-framework ${DIST_FOLDER}/IdentHubSDK.xcarchive/Products/Library/Frameworks/IdentHubSDKQES.framework \
		-framework ${DIST_FOLDER}/IdentHubSDK-Simulator.xcarchive/Products/Library/Frameworks/IdentHubSDKQES.framework \
		-output ${QES_FOLDER}/IdentHubSDKQES.xcframework
		
build-internalmodule-dependencies:build-identhub-core-xcframework build-identhub-bank-xcframework build-identhub-fourthline-xcframework build-identhub-qes-xcframework
		
build-dependencies:
	@echo "Building dependency binaries with Carthage…"
	carthage update --use-xcframeworks --platform ios

copy-fourtline:
	@echo "Copying fourthline…"
	cp -R ./Carthage/Build/ ./dist/fourthline

build: clean prepare build-binaries build-identhub-xcframework build-internalmodule-dependencies build-dependencies copy-fourtline
