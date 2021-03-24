//
//  ViewController.swift
//  Sample
//

import UIKit
import IdentHubSDK

class ViewController: UIViewController {

    // MARK: - Properties -
    @IBOutlet var statusView: UIStackView!
    @IBOutlet var statusState: UILabel!
    @IBOutlet var statusDesc: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        statusView.isHidden = true
    }

    // MARK: - Action methods -

    @IBAction func startBankIdentSDK(_ sender: Any) {
        statusView.isHidden = true

        do {
            let identHubManager = try IdentHubSession(rootViewController: self, sessionURL: identHubSessionURL)

            identHubManager.start(self)
        } catch let err as IdentSessionURLError {
            switch err {
            case .invalidSessionURL:
                updateStatus(false, desc: "Session URL is not valid, please contact with Solarisbank support team")
            case .invalidBaseURL:
                updateStatus(false, desc: "Session URL host is not valid in session URL")
            case .invalidSessionToken:
                updateStatus(false, desc: "Session token in url is not valid, please contact with Solarisbank support team")
            }
        } catch {
            updateStatus(false, desc: "Registered undefined error")
        }
    }

    // MARK: - Internal methods -

    private func updateStatus(_ isSuccess: Bool, desc: String) {
        statusView.isHidden = false

        if isSuccess {
            statusState.textColor = .green
            statusState.text = "Successful"
            statusDesc.textColor = .green
            statusDesc.text = "User ID: \(desc)"
        } else {
            statusState.textColor = .red
            statusState.text = "Failed"
            statusDesc.textColor = .red
            statusDesc.text = desc
        }
    }
}

extension ViewController: IdentHubSDKManagerDelegate {

    func didFinishWithSuccess(_ identification: String) {
        // - display success message on screen with identification -
        updateStatus(true, desc: identification)
    }

    func didFailureSession(_ failureReason: APIError) {
        // - display error message on screen -
        var failureReasonDesc = ""
        switch failureReason {
        case .authorizationFailed:
            failureReasonDesc = "indicates that authorization failed."
        case .malformedResponseJson:
            failureReasonDesc = "indicates that string received in the response couldn't been parsed."
        case .clientError:
            failureReasonDesc = "infidicates the error on the client's side."
        case .unauthorizedAction:
            failureReasonDesc = "action has not been authorized."
        case .resourceNotFound:
            failureReasonDesc = "resource has not been found."
        case .expectationMismatch:
            failureReasonDesc = "data mismatch."
        case .incorrectIdentificationStatus:
            failureReasonDesc = "the identification status was not allowed to proceed with the action."
        case .unprocessableEntity:
            failureReasonDesc = "data invalid or expired."
        case .internalServerError:
            failureReasonDesc = "indicates the internal server error."
        case .requestError:
            failureReasonDesc = "indicates build request error."
        case .unknownError:
            failureReasonDesc = "indicates that api client encountered an error not listed above."
        }

        updateStatus(false, desc: failureReasonDesc)
    }
}
