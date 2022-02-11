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
    @IBOutlet var versionLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        statusView.isHidden = true

        configureUI()
    }

    override func becomeFirstResponder() -> Bool {
        true
    }

    // MARK: - Action methods -

    @IBAction func startBankIdentSDK(_ sender: Any) {
        startIdentProcess()
    }

    // MARK: - Internal methods -

    private func configureUI() {
        sessionURLTV.layer.borderColor = UIColor.gray.cgColor
        sessionURLTV.layer.borderWidth = 1
        sessionURLTV.layer.cornerRadius = 5

        sessionURLTV.text = placeholderText
        sessionURLTV.textColor = .lightGray
        
        versionLbl.attributedText = "Ident SDK \(IdentHubSession.version())".withBoldText(IdentHubSession.version())
    }

    private func startIdentProcess() {
        statusView.isHidden = true

        do {
            let identHubManager = try IdentHubSession(rootViewController: self, sessionURL: sessionURLTV.text)
            
            identHubManager.start(self)
            
            identHubManager.start { result in
                switch result {
                case .success(let identification):
                    DispatchQueue.main.async {
                        self.updateStatus(true, desc: identification)
                    }
                case .failure(let failureReason):
                    DispatchQueue.main.async {
                        self.updateStatus(false, desc: "Session failed (\"\(failureReason.text())\"). Try again or create new session URL.")
                    }
                case .onConfirm(let identification):
                    // - display success message on screen with identification -
                    DispatchQueue.main.async {
                        self.updateStatus(true, desc: identification)
                    }
                }
            }
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
        sessionURLTV.resignFirstResponder()
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
        DispatchQueue.main.async {
            self.updateStatus(true, desc: identification)
        }
    }

    func didFailureSession(_ failureReason: APIError) {

        DispatchQueue.main.async {
            self.updateStatus(false, desc: "Session failed (\"\(failureReason.text())\"). Try again or create new session URL.")
        }
    }

    func didFinishOnConfirm(_ identification: String) {
        // - display success message on screen with identification -
        DispatchQueue.main.async {
            self.updateStatus(true, desc: identification)
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
