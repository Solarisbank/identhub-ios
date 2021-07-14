# Solarisbank IdentHub SDK
iOS SDK for Solarisbank IdentHub.

It provides an easy way to integrate identification provided by Solarisbank into your iOS app.

## Installation

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

## Usage
First you need to create an identification session via the Solarisbank API. The session will contain a URL that can be passed to the IdentHub SDK to create a new session.

```swift
import IdentHubSDK

class ViewController: UIViewController {
    @IBAction func startBankIdentSDK(_ sender: Any) {
        let identHubSessionURL = … // from the API
        let identHubSession = try IdentHubSession(rootViewController: self, sessionURL: identHubSessionURL)
        identHubSession.start(self)
    }
}

extension ViewController: IdentHubSDKManagerDelegate {

    func didFinishWithSuccess(_ identification: String) {
        DispatchQueue.main.async {
            // - display success message on screen with identification -
        }
    }

    func didFailureSession(_ failureReason: APIError) {

        DispatchQueue.main.async {
            // - display failure message -
            // - fetch reason description, call text method: failureReason.text()
        }
    }
}
```

## Example
You can open the example app in XCode to try it out.

You can find the example code in `Sample` directory.
