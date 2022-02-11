# Solarisbank IdentHub SDK
<img src="https://badgen.net/badge/bitcode/Enabled/green">

<!--
    spell-checker:words Fourthline Identhub Podfile Cartfile IBAN  
    spell-checker:ignore Swifty
-->

- [Solarisbank IdentHub SDK](#solarisbank-identhub-sdk)
  - [Overview](#overview)
  - [Compatibility Table](#compatibility-table)
  - [Integration](#integration)
    - [CocoaPods](#cocoapods)
      - [Dependency to Fourthline SDK](#dependency-to-fourthline-sdk)
    - [Carthage](#carthage)
  - [Example Usage](#example-usage)
  - [Identification callbacks](#identification-callbacks)
    - [Delegate protocol methods](#delegate-protocol-methods)
    - [Callback by using closures](#callback-by-using-closures)
  - [SDK Version](#sdk-version)
  - [Sample app](#sample-app)
  - [Troubleshooting](#troubleshooting)
    - [Pod repo add error](#pod-repo-add-error)
    - [SwiftyTesseract compilation error](#swiftytesseract-compilation-error)
    - [SwiftyTesseract upload to AppStore error](#swiftytesseract-upload-to-appstore-error)
    - [Bitcode compilation error](#bitcode-compilation-error)
    - [Crash during ZIP creation](#crash-during-zip-creation)
    - [Crash in pure ObjC applications](#crash-in-pure-objc-applications)
    - [iOS Simulator launch error for Xcode 12](#ios-simulator-launch-error-for-xcode-12)
    - [Xcode 12.3 errors using .framework dependencies](#xcode-123-errors-using-framework-dependencies)

## Overview
iOS SDK for Solarisbank IdentHub.

It provides an easy way to integrate identification provided by Solarisbank into your iOS app.

IdentHub SDK requires minimum iOS version 12.

## Compatibility Table

| SDK Version | Cocoa Xcode Compatible<br>.xcframework/.framework | Carthage Xcode Compatible<br>.framework | Minimum iOS support |
|:------------:|:----------------------------------------------------:|:----------------:|:--------:|
| 0.3.0 | 11.0 - 12.4                                                         | 12.3 - 12.4      | iOS 12 |
| 0.4.0 | 11.0 - 12.4                                                         | 12.3 - 12.4      | iOS 12 |
| 0.5.0 | 11.0 - 12.4                                                         | 12.3 - 12.4      | iOS 12 |
| 0.6.0 | 11.0 - 12.4                                                         | 12.3 - 12.4      | iOS 12 |
| 0.7.0 | 11.0 - 12.4                                                         | 12.3 - 12.4      | iOS 12 |
| 0.7.1 | 11.0 - 12.4                                                         | 12.3 - 12.4      | iOS 12 |
| 1.0.0 | 11.0 - 12.4                                                         | 12.3 - 12.4      | iOS 12 |
| 1.1.1 | 11.0 - 12.4                                                         | 12.3 - 12.4      | iOS 12 |
| 1.1.2 | 13.0 - 13.1                                                         | 13.0 - 13.1      | iOS 12 |
| 1.1.3 | 13.0 - 13.1                                                         | 13.0 - 13.1      | iOS 12 |
| 1.2.0 | 13.0 - 13.1                                                         | 13.0 - 13.1      | iOS 12 |
| 1.2.1 | 13.0 - 13.1                                                         | 13.0 - 13.1      | iOS 12 |
| 1.2.2 | 13.0 - 13.1                                                         | 13.0 - 13.1      | iOS 12 |

## Integration

You can add the desired IdentHub SDK modules to your project by using CocoaPods or Carthage dependency managers.

### CocoaPods

1. As a prerequisite, install CocoaPods on your machine (follow instructions at https://guides.cocoapods.org/using/getting-started.html).

 2. Add **Podfile** to the root of your project (or extend existing one):

```bash
source 'https://github.com/Fourthline-com/FourthlineSDK-iOS-Specs.git' # to add Fourthline private pod
source 'https://github.com/CocoaPods/Specs.git' # to add other public pods

use_frameworks!
inhibit_all_warnings!
platform :ios, '12.0'

target 'YourTargetName' do
  pod 'SolarisbankIdentHub', :git => "https://github.com/Solarisbank/identhub-ios.git", :tag => '1.2.2'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
    end
  end
end
```

3. Open *Terminal* and run `pod repo add fourthline-specs https://github.com/Fourthline-com/FourthlineSDK-iOS-Specs.git` command. You will be prompted to authenticate using the credentials you have been provided with in order to access the Fourthline SDK repository. (* if you experience any errors please see [Troubleshooting](#pod-repo-add-error))

4. For first installation, run `pod install` inside your project root folder.
    - To update the Fourthline SDK, update the *version* value and run `pod update` inside your project root folder.

5. Open your project and build it.

#### Dependency to Fourthline SDK
The Fourthline SDK is not publicly available. Please get in contact with Solarisbank to request access to it.

### Carthage

1. Create Cartfile in your projects folder:

    ```bash
    touch Cartfile
    ```

2. Include the source of the SDK in the Cartfile with the latest version of the SDK, e.g.:

    ```bash
    github "Solarisbank/identhub-ios" ~> 1.2.2
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

Add `Privacy - Camera Usage Description` and `Privacy - Location When In Use Usage Description` entries to Info.plist file, make sure that user granted access to Camera and Location services.

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

    func didFailureSession(_ failureReason: APIError) {
        DispatchQueue.main.async {
            // - display failure message
            // - check the IdentificationSession's status in the backend wether app should retry
        }
    }

    func didFinishOnConfirm(_ identification: String) {
        DispatchQueue.main.async {
            // - display a message stating the identification is in review -
        }
    }
}
```
</details>

## Identification callbacks

Callback system implemented by using delegate pattern or closure.

### Delegate protocol methods

<details>
  <summary>Output Delegate</summary>

```swift
/// Identification session results delegate
public protocol IdentHubSDKManagerDelegate: AnyObject {

    /// Session finished with successful result and returns identification string
    /// - Parameter identification: string value of the user identification
    func didFinishWithSuccess(_ identification: String)

    /// Identification session failed or interrupted with error
    /// - Parameter failureReason: error object
    func didFailureSession(_ failureReason: APIError)

    /// Session finished with fourthline signing on confirm step and returns identification string
    /// - Parameter identification: string value of the user identification
    func didFinishOnConfirm(_ identification: String)
}
```
</details>

```swift
func didFinishWithSuccess(_ identification: String)
```
Method notifies when identification session finished with success and returns identification session identifier in parameter

```swift
func didFailureSession(_ failureReason: APIError)
```

Method notifies when identification session finished or interrupted with error.
Ask your backend (receives the webhooks), if app able to retry or not.
App may retry as long as do not get a failed / rejected status on the session.

:warning: &nbsp; **Note that your app should not rely on the error details provided in the failure handler to deduce the status of an Identification. Information about the outcome of the Identification should be taken from the Identification's status only. Provision of the APIError object in the failure handler may be deprecated or presented differently in future releases of the IdentHub SDK.**

<details>
  <summary>APIError Description</summary>

```swift
// Common api error encountered throughout the app.
//
// - malformedResponseJson:  indicates that string received in the response couldn't been parsed.
// - clientError: indicates the error on the client's side.
// - authorizationFailed: indicates that authorization failed.
// - unauthorizedAction: action has not been authorized.
// - resourceNotFound: resource has not been found.
// - expectationMismatch: data mismatch's
// - incorrectIdentificationStatus: the identification status was not allowed to proceed with the action.
// - unprocessableEntity: data invalid or expired.
// - internalServerError: indicates the internal server error.
// - requestError: indicates build request error
// - locationError: indicates issue with fetching device location data
// - ibanVerfificationFailed: failed IBAN verification
// - paymentFailed: failed payment initiation
// - identificationDataInvalid: provided user data is not valid and should be creates one more time
// - fraudData: provided data defines as fraud
// - unsupportedResponse: SDK encountered a response that is not supported in this version
// - identificationNotPossible: SDK could not identify the user. Try your fallback identification method
// - unknownError: indicates that api client encountered an error not listed above.
public enum APIError: Error {
    case malformedResponseJson
    case clientError(error: ErrorDetail?)
    case authorizationFailed
    case unauthorizedAction
    case resourceNotFound
    case expectationMismatch
    case incorrectIdentificationStatus(error: ErrorDetail?)
    case unprocessableEntity
    case internalServerError
    case requestError
    case locationAccessError
    case locationError
    case ibanVerfificationFailed
    case paymentFailed
    case identificationDataInvalid(error: ErrorDetail?)
    case fraudData(error: ErrorDetail?)
    case unsupportedResponse
    case identificationNotPossible
    case unknownError
}
```
</details>
<br />

```swift
func didFinishOnConfirm(_ identification: String)
```
Method notifies when session finished with fourthline signing on confirm step and returns identification string
Method is optional and used only for the Fourthline signing session method.

### Callback by using closures

Callback as closure passed as start method parameter

```swift
/// Method starts identification process (BankID) with updating status by closure callback
/// - Parameter type: identification process session type: bankid, fourthline
/// - Parameter completion: closure with result object in parameter, result has two cases: success with id or failure with error
public func start(_ completion: CompletionHandler?)
```

CompletionHandler closure has enum input parameter with name: `IdentificationSessionResult`

<details>
  <summary>IdentificationSessionResult</summary>

```swift
/// Ident hub session result
public enum IdentificationSessionResult {
    /// success - successful result with identification string in parameter
    /// - identification: identification user session identifier
    case success(identification: String)

    /// failure - case used if identification process failed
    /// - Parameter failureReason: error object
    case failure(APIError)

    /// onConfirm - success result of the Fourthline signing flow with identification value string in parameter
    /// - identification: identification user session identifier
    case onConfirm(identification: String)
}
```
</details>

## SDK version
IdentHubSession class has static method `version()`.
Method returns current version of SDK in format (version + build number): `v1.0(1)`

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
If you get "Redefinition of module 'libtesseract'" and  "Redefinition of module 'libleptonica'" errors at *module.private.modulemap* file while building your app, comment out next lines of code:

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
For Xcode 11.X, if ZIPFoundation framework was integrated via Carthage, you may experience crash after calling *createZipFile(with:)* method on instance of *Zipper* class. To fix this issue, you need to update build settings of ZIPFoundation project and build framework manually.
- Go to *YourProjectFolder/Carthage/Checkouts/ZIPFoundation* folder.
- Open *ZIPFoundation.xcodeproj* file with Xcode.
- Select *ZIPFoundation* target.
- Go to *Build Settings*, search for *Linking* section.
- Change value of *Compatibility Version* property from empty to "1".
- Build framework and use it in your app.

For Xcode 12.X, make sure you are using 0.9.11 version of framework.

### Crash in pure ObjC applications
If you get error message similar to next one: "Class XXX is implemented in both YYY and /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx/libswiftCore.dylib. One of the two will be used. Which one is undefined.", you need to add empty swift file to your pure ObjC application, together with bridging file (will be created automatically by Xcode).

### iOS Simulator launch error for Xcode 12
If you get error "/Path/To/Your/Project/ProjectName.xcodeproj Building for iOS Simulator, but the linked and embedded framework 'FrameworkName.framework' was built for iOS.", you need to rebuild that framework with arm64 architecture excluded for iOS Simulator.

For this go to Build settings of framework target in framework project and make sure that *Excluded Architectures* property contains *arm64* value for *Any iOS Simulator SDK* option for desired build target (*Debug*, *Release*)

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
