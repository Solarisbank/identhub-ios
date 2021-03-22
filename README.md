# BankIdentSKD
Welcome to the **BankIdentSDK** project. It's an SDK made for onboarding the person with their bank details.

## Configuration

### SDK Prerequisites

- [Homebrew](https://brew.sh)
- [Carthage](https://github.com/Carthage/Carthage) (`brew install carthage`)

### SDK Instalation

1. Create Cartfile in your projects folder:

    ```bash
    touch Cartfile
    ```

2. Include the source of the SDK in the Cartfile with the latest version of the SDK, e.g.:

    ```bash
    # example:
    github "solarisbank/bankidentsdk" ~> 1.0.0 
    ```

3. Run carthage script:

    ```bash
    carthage bootstrap --platform iOS --cache-builds
    ```

4. Follow [Carthage framework setup guidelines](https://github.com/Carthage/Carthage#if-youre-building-for-ios-tvos-or-watchos):
- Skip creating Cartfile step
- Skip `carthage update` step

5. Open your project and build it.

6. Import BankIdentSDK, create an instance of `BankIdentSDKManager` and call `start`.
