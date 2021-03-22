//
//  ViewController.swift
//  Sample
//

import UIKit
import IdentHubSDK

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func startBankIdentSDK(_ sender: Any) {

        do {
            let identHubManager = try IdentHubSession(rootViewController: self, sessionURL: identHubSessionURL)

            identHubManager.start(self)
        } catch let err as IdentSessionURLError {
            switch err {
            case .invalidSessionURL:
                print("Session URL is not valid, please contact with Solarisbank support team")
            case .invalidBaseURL:
                print("Session URL host is not valid in session URL")
            case .invalidSessionToken:
                print("Session token in url is not valid, please contact with Solarisbank support team")
            }
        } catch {
            print("Registered undefined error")
        }
    }
}

extension ViewController: IdentHubSDKManagerDelegate {

    func didFinishWithSuccess(_ identification: String) {
        // - display success message on screen with identification -
    }

    func didFailureSession(_ failureReason: Error) {
        // - display error message on screen -
    }
}
