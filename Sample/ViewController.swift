//
//  ViewController.swift
//  Sample
//

import UIKit
import IdentHubSDK

let placeholderText = "Please enter session URL"

class ViewController: UIViewController {

    // MARK: - Properties -
    @IBOutlet var sessionURLTV: UITextView!
    @IBOutlet var statusView: UIStackView!
    @IBOutlet var statusState: UILabel!
    @IBOutlet var statusDesc: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        statusView.isHidden = true

        setupUI()
    }

    // MARK: - Action methods -

    @IBAction func startBankIdentSDK(_ sender: Any) {
        startIdentProcess(.bankID)
    }
    @IBAction func startFourthlineIdentSDK(_ sender: Any) {
        startIdentProcess(.fouthline)
    }

    // MARK: - Internal methods -

    private func setupUI() {
        sessionURLTV.layer.borderColor = UIColor.gray.cgColor
        sessionURLTV.layer.borderWidth = 1
        sessionURLTV.layer.cornerRadius = 5

        sessionURLTV.text = placeholderText
        sessionURLTV.textColor = .lightGray
    }

    private func startIdentProcess( _ type: IdentificationSessionType) {
        statusView.isHidden = true

        do {
            let identHubManager = try IdentHubSession(rootViewController: self, sessionURL: sessionURLTV.text)

            identHubManager.start(type, delegate: self)
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

    private func updateStatus(_ isSuccess: Bool, desc: String) {
        statusView.isHidden = false

        if isSuccess {
            statusState.textColor = UIColor(named: "success")
            statusState.text = "Successful"
            statusDesc.textColor = UIColor(named: "success")
            statusDesc.text = "User ID: \(desc)"
        } else {
            statusState.textColor = UIColor(named: "error")
            statusState.text = "Failed"
            statusDesc.textColor = UIColor(named: "error")
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

        DispatchQueue.main.async {
            self.updateStatus(false, desc: failureReasonDesc)
        }
    }
}

extension ViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .darkGray
        }
    }
}
