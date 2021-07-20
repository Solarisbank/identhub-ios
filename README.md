# Solarisbank IdentHub SDK
<img src="https://badgen.net/badge/bitcode/Enabled/green">

- [Overview](#overview)
- [Compatiblity Table](#compatibility-table)
- [Intergration](#intergration)
  * [CocoaPods](#cocoapods)
  * [Carthage](#carthage)
- [Example usage](#example-usage)
- [Sample app](#sample-app)
- [Troubleshooting](#troubleshooting)
  * [Pod repo add error](#pod-repo-add-error)
  * [SwiftyTesseract compilation error](#swiftytesseract-compilation-error)
  * [SwiftyTesseract upload to AppStore error](#swiftytesseract-upload-to-appstore-error)
  * [Bitcode compilation error](#bitcode-compilation-error)
  * [iOS Simulator launch error for Xcode 12](#ios-simulator-launch-error-for-xcode-12)
  * [Xcode 12.3 errors using *.framework* dependencies](#xcode-123-errors-using-framework-dependencies)

## Overview
iOS SDK for Solarisbank IdentHub.

It provides an easy way to integrate identification provided by Solarisbank into your iOS app.

IdentHub SDK requires minimum iOS version 12.

## Compatibility Table

| SDK Version | Cocoa Xcode Compatible<br>.xcframework/.framework | Carthage Xcode Compatible<br>.framework | Minimum iOS support |
|:------------:|:----------------------------------------------------:|:----------------:|:--------:|
| 0.3.0 | 11.0 - 12.4                                                         | 12.3 - 12.4      | iOS 12 |


## Intergration

You can add the desired IdentHub SDK modules to your project by using CocoaPods or Carthage dependency managers.

### CocoaPods

1. As a prerequisite, install CocoaPods on your machine (follow instructions at https://guides.cocoapods.org/using/getting-started.html).

 2. Add **Podfile** to the root of your project (or extend existing one):

```bash
source 'https://github.com/Fourthline-com/FourthlineSDK-iOS-Specs.git' # to add Fourthline private pod
source 'https://github.com/CocoaPods/Specs.git' # to add other public pods

$version = 'version.to.integrate'
use_frameworks!
platform :ios, '12.0'
target 'YourTargetName' do

    pod 'SolarisbankIdentHub', :git => "https://github.com/Solarisbank/identhub-ios.git" #use private repository
    pod 'FourthlineSDK', $version # will add all available module
    pod 'SwiftyTesseract', '2.2.3' # to enable OCR in DocumentScanner
    pod 'ZIPFoundation', '0.9.11' # to create ZIP from KYCInfo
    
end
```

3. Open *Terminal* and run `pod repo add fourthline-specs https://github.com/Fourthline-com/FourthlineSDK-iOS-Specs.git` command. You will be prompted to authenticate using the credentials you have been provided with in order to access the Fourthline SDK repository. (* if you experience any errors please see [Troubleshooting](#pod-repo-add-error))

4. For first installation, run `pod install` inside your project root folder.
    - To update the Fourthline SDK, update the *version* value and run `pod update` inside your project root folder.

5. Open your project and build it.

### Carthage

1. Create Cartfile in your projects folder:

    ```bash
    touch Cartfile
    ```

2. Include the source of the SDK in the Cartfile with the latest version of the SDK, e.g.:

    ```bash
    github "Solarisbank/identhub-ios" ~> 0.1.0
    ```

3. Run carthage script:

    ```bash
    carthage bootstrap --platform iOS --cache-builds
    ```

4. Follow [Carthage framework setup guidelines](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos):
- Skip creating Cartfile step
- Skip `carthage update` step

5. Open your project and build it.

## Example Usage

First you need to create an identification session via the Solarisbank API. The session will contain a URL that can be passed to the IdentHub SDK to create a new session.

<details>
  <summary>Swift</summary>
  
```swift
import SolarisbankIdentHub

// ... View Controller which is going to present IdentHub SDK
class ViewController: UIViewController {
    @IBAction func startBankIdentSDK(_ sender: Any) {
        let identHubSessionURL = … // from the API
        let identHubSession = try IdentHubSession(rootViewController: self, sessionURL: identHubSessionURL)
        identHubSession.start(self)
    }
}

// MARK: Delegate
extension ViewController: IdentHubSDKManagerDelegate {

    func didFinishWithSuccess(_ identification: String) {
        DispatchQueue.main.async {
            // - display success message on screen with identification -
        }
    }

    func didFailureSession(_ failureReason: Error) {

        DispatchQueue.main.async {
            // - display failure message -
        }
    }
}
```
</details>

## Sample app
You can open the example app in XCode to try it out.

You can find the example code in `Sample` directory.

## Troubleshooting

### Pod repo add error
While trying to call `pod repo add fourthline-specs https://github.com/Fourthline-com/FourthlineSDK-iOS-Specs.git` if you experience the following error:
```
remote: Invalid username or password
fatal: Authentication failed for 'https://github.com/Fourthline-com/FourthlineSDK-iOS-Specs.git/'
```
Fourthline requires to use GitHub 2 factor authentication, please use a PAT instead of a password when trying to authenticate.
How to create a PAT can be found at -> https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token

### SwiftyTesseract compilation error
If you get "Redefenition of module 'libtesseract'" and  "Redefenition of module 'libleptonica'" errors at *module.private.modulemap* file while building your app, comment out next lines of code:

```bash
module libtesseract {
    export *
}

module libleptonica {
    export *
}
```
### SwiftyTesseract upload to AppStore error 
If you get "Missing modules 'libtesseract', 'libleptonica'" while uploading app to AppStore, make sure that *module.private.modulemap* file is not missing at *SwiftyTeseeract.framework/Modules/* folder. You can find content of file in previous section.

### Bitcode compilation error
If you get "bitcode bundle could not be generated because '/Path/To/Framework/FrameworkName.framework/FrameworkName' was built without full bitcode." error, you need to rebuild that framework with bitcode enabled.

For this go to Build settings of framework target in framework project and make sure:
- *Enable bitcode* is set to *Yes*.
- *Other C Flags* contains *-fembed-bitcode* value.
- User defined settings contain *BITCODE_GENERATION_MODE* key with *bitcode* value.

Rebuild and reimport problematic framework.

### Crash during ZIP creation
For Xcode 11.X, if ZIPFoundation framework was intergrated via Carthage, you may experience crash after calling *createZipFile(with:)* method on instance of *Zipper* class. To fix this issue, you need to update build settings of ZIPFoundation project and build framework manually.
- Go to *YourProjectFolder/Carthage/Checkouts/ZIPFoundation* folder.
- Open *ZIPFoundation.xcodeproj* file with Xcode.
- Select *ZIPFoundation* target.
- Go to *Build Settings*, search for *Linking* section.
- Change value of *Compatibility Version* property from empty to "1".
- Build framework and use it in your app.

For Xcode 12.X, make sure you are using 0.9.11 version of framework.

### Crash in pure ObjC applications
If you get error message similat to next one: "Class XXX is implemented in both YYY and /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx/libswiftCore.dylib. One of the two will be used. Which one is undefined.", you need to add empty swift file to your pure ObjC application, together with bridging file (will be created automatically by Xcode).

### iOS Simulator launch error for Xcode 12
If you get error "/Path/To/Your/Project/ProjectName.xcodeproj Building for iOS Simulator, but the linked and embedded framework 'FrameworkName.framework' was built for iOS.", you need to rebuild that framework with arm64 architecture excluded for iOS Simulator.

For this go to Build settings of framework target in framework project and make sure that *Excluded Architectures* property containt *arm64* value for *Any iOS Simulator SDK* option for desired build target (*Debug*, *Release*)

Rebuild and reimport problematic framework.

Alternatively, you can add the following script at the end of the *Podfile*:
```bash
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
        end
    end
end
```

### Xcode 12.3 errors using .framework dependencies
If you get error  ```Building for iOS, but the linked and embedded framework 'FourthlineCore.framework' was built for iOS + iOS Simulator.```
<br>This was introduced in Xcode 12.3 and is a reminded for pushing teams to use *.xcframeworks* instead of *.frameworks* for dependencies.

Please go to ```Build Settings``` and set ```Validate Workspace``` to **NO** (if is already set, change it to **YES** and change it back to **NO**, it seems to be an Xcode visual bug for now, by default is set to **YES(Error)**)

| `Validate Workspace` | Description                        |
|:---------------------|:-------------------------------------|
| YES                  | validate workspace and show warnings |
| NO                    | skip validation of workspace         |
| YES(Error)           | validate workspace and show errors   |
