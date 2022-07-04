//
//  QuitPopUpViewController.swift
//  IdentHubSDK
//

import UIKit

/// PopUpWindowViewController which displays quit flow.
final internal class QuitPopUpViewController: PopUpWindowViewController {

    /// Quit action.
    var quitAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setTitle(Localizable.Quiting.title)
        setDescription(Localizable.Quiting.description)
        setPrimaryButtonTitle(Localizable.Common.quit)
        setPrimaryButtonAction { [weak self] in
            self?.quitAction?()
        }
        setSecondaryButtonTitle(Localizable.Quiting.stay)
        setSecondaryButtonAction { [weak self] in
            self?.dismiss(animated: false)
        }
    }
}
