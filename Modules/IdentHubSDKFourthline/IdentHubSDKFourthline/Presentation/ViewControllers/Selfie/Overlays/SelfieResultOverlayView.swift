//
//  SelfieResultOverlayView.swift
//  IdentHubSDKFourthline
//

import UIKit
import IdentHubSDKCore

class SelfieResultOverlayView: UIView {

    // MARK: - Properties -
    @IBOutlet var retakeBtnTitle: UILabel!
    @IBOutlet var confirmBtnTitle: UILabel!
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var resultContent: UIImageView!

    var onDismiss: (() -> Void)?
    var onRetake: (() -> Void)?
    var onConfirm: (() -> Void)?
    
    // MARK: - Public methods -
    func configureUI(_ colors: Colors) {

        retakeBtnTitle.text = Localizable.Selfie.retake
        confirmBtnTitle.text = Localizable.Selfie.confirm
        confirmBtnTitle.textColor = .white
        confirmBtn.tintColor = colors[.primaryAccent]
        titleLbl.text = Localizable.Selfie.confirmSelfie
    }

    // MARK: - Action methods -
    @IBAction func didClickRetake(_ sender: UIButton) {
        onRetake?()
    }

    @IBAction func didClickConfirm(_ sender: UIButton) {
        onConfirm?()
    }

    @IBAction func didClickDismiss(_ sender: UIButton) {
        onDismiss?()
    }

}
